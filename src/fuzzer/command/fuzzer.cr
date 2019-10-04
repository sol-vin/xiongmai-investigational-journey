require "json"
require "uuid"
require "logger"

require "../xmmessage"
require "../errors"
require "../xmsocket"
require "../dahua_hash"
require "../commands/*"

class Command::Fuzzer
  CLEAR_SCREEN = "\e[H\e[2J"



  LOG_FILE = File.open("./logs/xmfuzzer.log", "w+")
  LOG      = Logger.new LOG_FILE

  # Maximum amount of time
  MAX_TIMEOUT = 30

  POOL_MAX = 16

  @total_sockets_spawned = 0
  # Hash of XMSocketTCP UUID to a XMSocketTCP
  @socket_pool : Hash(UUID, FuzzXMSocketTCP) = {} of UUID => FuzzXMSocketTCP

  @result_channel : Channel(Command::Fuzzer::Result?) = Channel(Command::Fuzzer::Result?).new
  @results = [] of Command::Fuzzer::Result
  @template : XMMessage = XMMessage.new
  @start_time : Time = Time.now

  getter state : Symbol = :stopped
  getter slow_mode = false
  getter main_fiber_check_in : Time = Time.new(1970, 1, 1, 0, 0, 0)

  getter reciever_state : Symbol = :stopped
  getter reciever_fiber_check_in : Time = Time.new(1970, 1, 1, 0, 0, 0)

  SESSION_REGEX = /,?\h?\"SessionID\"\h\:\h\"0x.{8}\"/

  # Camera's down time, 120 seconds.
  CAMERA_DOWN_TIME = Time::Span.new(0, 0, 120)

  COMMAND_LIST = "./rsrc/lists/list_of_commands.txt"

  def initialize(@commands : Enumerable = (0x0000..0x08FF),
                 @output : IO = STDOUT,
                 @username = "admin",
                 @password = "password",
                 hash_password = true,
                 @login = true,
                 @target_ip = "192.168.1.99",
                 @template = XMMessage.new)
    Signal::INT.trap do
      puts "CTRL-C INTERRUPT!"
      close
      exit
    end

    @password = Dahua.digest(@password) if hash_password

    _clear_screen

    _make_pool
  end

  def is_running?
    state != :stopped
  end

  def wait
    until @state == :stopped
      sleep 5
    end
  end

  def run
    unless is_running?
      @is_running = true
      @start_time = Time.now
      # TODO: Start all the fibers
    end
  end

  def close
    @socket_pool.each do |uuid, socket|
      socket.close
      socket.wait_channel.close
      socket.manage_channel.close
    end
    @result_channel.close

    @is_running = false
    @state = :stopped
  end

  private def _clear_screen
    puts CLEAR_SCREEN
  end

  # Makes a pool of sockets, will close sockets that are already open if called while sockets are still open in the pool
  private def _make_pool
    unless @socket_pool.empty?
      @socket_pool.each do |uuid, socket|
        socket.close
      end
    end

    @socket_pool = {} of UUID => FuzzXMSocketTCP

    POOL_MAX.times do |i|
      success = false

      until success
        begin
          _add_socket_to_pool(_make_new_socket)
          success = true
        rescue e
          if e.is_a? XMError::Exception
            _clear_screen
            puts "Waiting for camera to come online"
            puts e.inspect
          else
            raise e
          end
        end
      end
    end
  end

  private def _make_new_socket
    socket = FuzzXMSocketTCP.new(@target_ip, TCP_PORT)
    @total_sockets_spawned += 1
    socket
  end

  private def _add_socket_to_pool(socket)
    # Close socket if it's already a part of the pool
    @socket_pool[socket.uuid].close if @socket_pool[socket.uuid]?
    # Replace the closed socket
    @socket_pool[socket.uuid] = socket
  end

  private def _replace_socket(socket_uuid : UUID)
    # get the two sockets
    old_socket = @socket_pool[socket_uuid]
    new_socket = _make_new_socket

    # transfer uuid so they go to the same place
    new_socket.uuid = old_socket.uuid

    # Transfer all data
    new_socket.command = old_socket.command
    new_socket.timeout = old_socket.timeout
    new_socket.state = :replaced
    new_socket.log = "REPLACED #{Time.now}"

    # close old and add new
    _add_socket_to_pool new_socket
  end

  private def _request_replace_and_wait(uuid : UUID)
    @socket_pool[uuid].state = :sending_manage_request
    @socket_pool[uuid].manage_channel.send nil
    @socket_pool[uuid].state = :recieve_wait_request
    @socket_pool[uuid].wait_channel.recieve
    @socket_pool[uuid].state = :replaced
  end

  private def _find_free_socket : UUID?
    socket = @socket_pool.find { |uuid, socket| socket.state == :free }
    if socket
      socket[0]
    else
      nil
    end
  end

  private def _ping
    success = false
    begin
      socket = XMSocketTCP.new(@target_ip, TCP_PORT)
      socket.send_message Command::GetSafetyAbility.new
      socket.receive_message
      success = true
    rescue e
    end
    success
  end

  private def _run_command(uuid : UUID, command : UInt16)
    @socket_pool[uuid].command = command
    @socket_pool[uuid].state = :started
    @socket_pool[uuid].timeout = Time.now

    success = false

    result = CommandResult.new
    result.message = @template.clone
    result.message.command = command

    until success || (Time.now - @socket_pool[uuid].timeout.to_i) > @max_timeout
      begin
        if @login
          @socket_pool[uuid].state = :logging_in
          @socket_pool[uuid].login(@username, @password)
          @socket_pool[uuid].state = :logged_in
        end

        @socket_pool[uuid].state = :sending
        @socket_pool[uuid].send_message result.message
        @socket_pool[uuid].state = :receiving
        result.reply = @socket_pool[uuid].receive_message
        @socket_pool[uuid].state = :recieved

        success = true
      rescue e : XMError::Exception
        socket_is_down = false
        if e.is_a? XMError::ReceiveTimeout
          # TODO: ADD CHECK TO SEE IF CAMERA IS REALLY DOWN
        else
          socket_is_down = true
          @socket_pool[uuid].log = "spawn socket: #{e.inspect} #{Time.now}"
          @socket_pool[uuid].state = :error
          result.error = e.inspect
        end
        if socket_is_down
          begin
            _request_replace_and_wait(uuid)
          rescue e : XMError::Exception
            result.error = e.inspect
            @socket_pool[uuid].log = "sleeping socket: #{e.inspect} #{Time.now}"
            @socket_pool[uuid].state = :error
            sleep 10
          rescue e : Exception
            result.error = e.inspect
            @socket_pool[uuid].state = :error
            @socket_pool[uuid].log = "replace_socket: #{e.inspect} #{Time.now}"
            raise e
          end
        end
      rescue e : Exception
        result.error = e.inspect
        @socket_pool[uuid].state = :error
        @socket_pool[uuid].log = "BAD ERROR: #{e.inspect} #{Time.now}"
        raise e
      end

      Fiber.yield
    end

    @socket_pool[uuid].state = :finished
    @socket_pool[uuid].log = "Finished #{@socket_pool[uuid].command.to_s(16)}"
    _request_replace_and_wait(uuid)
    @socket_pool[uuid].state = :sending_result
    @result_channel.send result
    @socket_pool[uuid].state = :free
  end

  # TODO: Limit to one during slow mode
  private def _spawn_command(command : UInt16)
    socket = nil
    until socket
      _main_check_in
      @state = "finding socket for #{command.to_s 16}"
      socket_uuid = find_free_socket
      socket = @socket_pool[socket_uuid]?
      Fiber.yield
    end

    spawn do
      _run_command(socket.as(XMSocketTCP).uuid, command)
    end
  end

  private def _main_check_in
    @main_fiber_check_in = Time.now
  end

  private def _spawn_main
    spawn do
      @state = :started

      @commands.each do |command|
        @state = :incrementing
        @current_command = command

        _spawn_command(command.to_u16)
        Fiber.yield
      end

      bad_results.each do |result|
        @state = :checking_bad_results

        _spawn_command(result.message.command)
        sleep 1
      end
      
      until @socket_pool.values.all? {|socket| socket.state == :free}
        @state = :waiting_for_finish
        Fiber.yield
      end

      close
      @state = :stopped
    end
  end

  private def _receiver_check_in
    @receiver_fiber_check_in = Time.now
  end

  private def _spawn_reciever
    spawn do
      @receiver_state = :started
      until @state = :stopped || !is_running?
        _receiver_check_in
        @receiver_state = :receiving
        result = @result_channel.receive?
        @receiver_state = :received
        @results << result if result
        Fiber.yield
      end
      @reciever_state = :stopped
    end
  end

  private def _spawn_socket_managers
    @socket_pool.keys.each do |uuid|
      @socket_pool[uuid].manage_state = :started
      until !is_running? || @state == :stopped
        success = false
        until success || !is_running? || @state = :stopped
          begin
            @socket_pool[uuid].manage_state = :waiting_for_signal
            @socket_pool[uuid].manage_channel.receive
            @socket_pool[uuid].manage_state = :restarting
            _replace_socket(uuid)
            @socket_pool[uuid].manage_state = :notify
            @socket_pool[uuid].wait_channel.send nil
            @socket_pool[uuid].manage_state = :success
            success = true
          rescue e : Channel::ClosedError
            # Do nothing
          rescue e : XMError::Exception
            @socket_pool[uuid].manage_state = :error
          end
        end
      end
    end
  end
end
