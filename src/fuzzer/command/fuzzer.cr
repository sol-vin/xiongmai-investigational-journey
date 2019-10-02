class Command::Fuzzer
  CLEAR_SCREEN = "\e[H\e[2J"

  private def clear_screen
    puts CLEAR_SCREEN
  end

  LOG_FILE = File.open("./logs/xmfuzzer.log", "w+")
  LOG      = Logger.new LOG_FILE

  POOL_MAX = 16

  @total_sockets_spawned = 0
  # Hash of XMSocketTCP UUID to a XMSocketTCP
  @socket_pool : Hash(UUID, FuzzXMSocketTCP) = {} of UUID => FuzzXMSocketTCP

  @template : XMMessage = XMMessage.new
  @start_time : Time = Time.now

  getter state : Symbol = :stopped
  getter main_fiber_check_in : Time = Time.new(1970, 1, 1, 0, 0, 0)

  def is_running?
    state != :stopped
  end

  SESSION_REGEX = /,?\h?\"SessionID\"\h\:\h\"0x.{8}\"/

  # Camera's down time, 120 seconds.
  CAMERA_DOWN_TIME = Time::Span.new(0, 0, 120)

  COMMAND_LIST = "./rsrc/lists/list_of_commands.txt"

  def initialize(@command : Enumerable = (0x0000..0x08FF),
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

    clear_screen

    _make_pool
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
        end
      rescue e
        if e.is_a? XMError::Exception
          clear_screen
          puts "Waiting for camera to come online"
          puts e.inspect
        else
          raise e
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
    @socket_pool[socket.uuid]@socket_pool[socket.uuid] = socket
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
    @socket_pool[uuid].state = :recieved_wait_request
  end

  private def find_free_socket : UUID?
    socket = @socket_pool.find { |uuid, socket| socket.state == :free }
    if socket
      socket[0]
    else
      nil
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
    @is_running? = false
    @state = :stopped
  end

  private def _run_command(uuid : UUID, command : UInt16)
  end

  private def _spawn_command(command : UInt16)
    socket = nil
    until socket
      main_check_in
      @state = "finding socket for #{command.to_s 16}"
      socket_uuid = find_free_socket
      socket = @socket_pool[socket_uuid]?
      Fiber.yield
    end

    spawn do
      _run_command(socket.as(XMSocketTCP).uuid, command)
    end
  end
end
