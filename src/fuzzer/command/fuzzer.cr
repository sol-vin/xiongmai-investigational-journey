require "../../requires"

require "./fuzz_xmsocket"
require "./command_result"


class Command::Fuzzer
  # Port for TCP communication
  TCP_PORT = 34567
  # Port for UDP communication
  UDP_PORT = 34568
  
  LOG_FILE = File.open("./logs/xmfuzzer.log", "w+")
  LOG      = Logger.new LOG_FILE

  # Maximum amount of time
  MAX_TIMEOUT = 30

  POOL_MAX = 16

  @total_sockets_spawned = 0
  # Hash of XMSocketTCP UUID to a XMSocketTCP
  @socket_pool : Hash(UUID, FuzzXMSocketTCP) = {} of UUID => FuzzXMSocketTCP

  # The channel that is used to communicate found results to their proper place
  @result_channel : Channel(Command::Fuzzer::Result?) = Channel(Command::Fuzzer::Result?).new

  getter output_channel : Channel(Command::Fuzzer::Result) = Channel(Command::Fuzzer::Result).new

  # Template command to use
  getter template : XMMessage = XMMessage.new
  # When the program started
  getter start_time : Time = Time.now

  getter state : Symbol = :stopped
  getter main_fiber_check_in : Time = Time.new(1970, 1, 1, 0, 0, 0)

  getter reciever_state : Symbol = :stopped
  getter reciever_fiber_check_in : Time = Time.new(1970, 1, 1, 0, 0, 0)

  # TODO: Implement slow mode
  getter slow_mode_state = :stopped
  getter slow_mode_fiber_check_in : Time = Time.new(1970, 1, 1, 0, 0, 0)

  getter current_command : UInt16 = 0_u16
  getter run_commands : UInt16 = 0_u16


  SESSION_REGEX = /,?\h?\"SessionID\"\h\:\h\"0x.{8}\"/

  # Camera's down time, 120 seconds.
  CAMERA_DOWN_TIME = Time::Span.new(0, 0, 120)

  COMMAND_LIST = "./rsrc/lists/list_of_commands.txt"

  def initialize(@commands : Enumerable = (0x03e0..0x08FF),
                 @username = "admin",
                 @password = "",
                 hash_password = true,
                 @login = true,
                 @target_ip = "192.168.1.10",
                 @template = XMMessage.new)

    @password = Dahua.digest(@password) if hash_password

    # TODO: Can we move this?
    _make_pool
  end

  # Is this service running?
  def is_running?
    state != :stopped
  end

  # Block this fiber until the machine stops
  def wait
    until @state == :stopped
      sleep 5
    end
  end

  # Run the fuzzer
  def run
    unless is_running?
      @is_running = true
      @start_time = Time.now
      @state = :started

      _spawn_main
      _spawn_reciever
      _spawn_socket_managers
    end
  end

  # Close all the sockets
  def close
    @socket_pool.each do |uuid, socket|
      socket.close
      socket.wait_channel.close
      socket.manage_channel.close
    end
    @result_channel.close
    @output_channel.close

    @is_running = false
    @state = :stopped
  end

  # Makes a pool of sockets, will close sockets that are already open if called while sockets are still open in the pool
  private def _make_pool(number = POOL_MAX)
    unless @socket_pool.empty?
      @socket_pool.each do |uuid, socket|
        socket.close
      end
    end

    @socket_pool = {} of UUID => FuzzXMSocketTCP

    number.times do |i|
      success = false
      until success
        begin
          _add_socket_to_pool(_make_new_socket)
          success = true
        rescue e
          if e.is_a? XMError::Exception
            # Do nothing and wait
          else
            raise e
          end
        end
      end
    end
  end

  # Makes a new socket.
  # DO NOT USE WITHOUT PROPER LOCKING
  private def _make_new_socket
    socket = FuzzXMSocketTCP.new(@target_ip, TCP_PORT)
    @total_sockets_spawned += 1
    socket
  end

  # Adds a socket to the pool
  # DO NOT USE WITHOUT PROPER LOCKING
  private def _add_socket_to_pool(socket)
    # Close socket if it's already a part of the pool
    @socket_pool[socket.uuid].close if @socket_pool[socket.uuid]?
    # Replace the closed socket
    @socket_pool[socket.uuid] = socket
  end

  # Replaces a socket to the pool
  # DO NOT USE WITHOUT PROPER LOCKING
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

  # Requests a specific socket gets replaced by the socket manager
  private def _request_replace_and_wait(uuid : UUID)
    @socket_pool[uuid].state = :sending_manage_request
    @socket_pool[uuid].manage_channel.send nil
    @socket_pool[uuid].state = :recieve_wait_request
    @socket_pool[uuid].wait_channel.receive
    @socket_pool[uuid].state = :replaced
  end

  # Looks through the sockets and sees if any are free
  private def _find_free_socket : UUID?
    socket = @socket_pool.find { |uuid, socket| socket.state == :free }
    if socket
      socket[0]
    else
      nil
    end
  end

  # opens a new socket and runs a command, if it receives a response, we know the camera is still operational
  private def _ping
    success = false
    begin
      socket = XMSocketTCP.new(@target_ip, TCP_PORT)
      socket.send_message Command::GetSafetyAbility::Request.new
      xmm = socket.receive_message
      success = !!xmm
    rescue e
    end
    success
  end

  # Run a command on a specific socket
  private def _run_command(uuid : UUID, command : UInt16)
    # Assign the important values to the socket
    @socket_pool[uuid].command = command
    @socket_pool[uuid].state = :started
    @socket_pool[uuid].timeout = Time.now

    success = false

    # Create a new result for this command
    result = Command::Fuzzer::Result.new
    result.message = @template.clone
    result.message.command = command

    # Keep looping until we succeed or we hit our timeout for the command
    until success || (Time.now - @socket_pool[uuid].timeout).to_i > MAX_TIMEOUT
      begin
        # Attempt to login
        if @login
          @socket_pool[uuid].state = :logging_in
          @socket_pool[uuid].login(@username, @password)
          @socket_pool[uuid].state = :logged_in
        end

        # Send the command
        @socket_pool[uuid].state = :sending
        @socket_pool[uuid].send_message result.message
        # Receive the command
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
          rescue e : XMError::SocketException
            result.error = e.inspect
            @socket_pool[uuid].log = "sleeping socket: #{e.inspect} #{Time.now}"
            @socket_pool[uuid].state = :error
            sleep 10
          rescue e : Exception
            result.error = e.inspect
            @socket_pool[uuid].log = "replace_socket: #{e.inspect} #{Time.now}"
            @socket_pool[uuid].state = :error
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
  # Makes a new fiber that hosts socket.
  private def _spawn_command(command : UInt16)
    socket = nil
    until socket
      _main_check_in
      @state = :finding_socket
      socket_uuid = _find_free_socket
      socket = @socket_pool[socket_uuid]?
      Fiber.yield
    end

    spawn do
      _run_command(socket.as(XMSocketTCP).uuid, command)
    end
  end

  # Timestamp the last time the main fiber was run
  private def _main_check_in
    @main_fiber_check_in = Time.now
  end

  # Spawn the main fiber for main, which handles incrementing the command, and assigning the task
  private def _spawn_main
    spawn do
      @commands.each do |command|
        @state = :incrementing
        @current_command = command
        @run_commands += 1

        _spawn_command(command.to_u16)
        Fiber.yield
      end

      # TODO: FIGURE OUT HOW TO HANDLE BAD RESULTS
      # bad_results.each do |result|
      #   @state = :checking_bad_results

      #   _spawn_command(result.message.command)
      #   sleep 1
      # end
      
      until @socket_pool.values.all? {|socket| socket.state == :free}
        @state = :waiting_for_finish
        Fiber.yield
      end

      close
      @state = :stopped
    end
  end

  # Timestamp the last reciever run
  private def _receiver_check_in
    @receiver_fiber_check_in = Time.now
  end

  # Spawn the reciever fiber, which listens for new results and files them away
  private def _spawn_reciever
    spawn do
      @receiver_state = :started
      until @state == :stopped || !is_running?
        _receiver_check_in
        @receiver_state = :receiving
        result = @result_channel.receive?
        @receiver_state = :received
        @output_channel.send result
        Fiber.yield
      end
      @reciever_state = :stopped
    end
  end

  # Spawn the socket manager fiber, which listens for a socket to request a new socket, then replaces it and frees the socket for a command to be sent
  private def _spawn_socket_managers
    @socket_pool.keys.each do |uuid|
      @socket_pool[uuid].manage_state = :started
      until !is_running? || @state == :stopped
        success = false
        until success || !is_running? || @state == :stopped
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
