require "logger"
require "socket"



class Client
  STATES =[:send_broadcast, 
           :receive_cameras, 
           :send_login,
           :wait_for_login_reply,
           :main_phase,
           :closing,
           :closed]

  TCP_PORT = 34567
  UDP_PORT = 34568
  DB_PORT = 34568

  DB = "\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xfa\x05\x00\x00\x00\x00"
  DB_CLIENT_DST = Socket::IPAddress.new("255.255.255.255", 34569)
  DB_CLIENT_SRC = Socket::IPAddress.new("0.0.0.0", 5008)
  
  DBR = "\xff\x01\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xfb\x05" # Missing size at end!
  DBR_CLIENT_SRC = Socket::IPAddress.new("0.0.0.0", 34569)

  DBR_FUNCTION_NAME = "NetWork.NetCommon"
  DBR_CHANNEL_NUM = 1
  DBR_DEVICE_TYPE = 1
  DBR_HOSTNAME = "LocalHost"
  DBR_HTTP_PORT = 80
  DBR_MAX_BPS = 0
  DBR_MON_MODE = "TCP"
  DBR_NET_CONNECT_STATE = 0
  DBR_OTHER_FUNCTION = "D=2019-01-01 00:00:00 V=c81a720f25e258c"
  DBR_SSL_PORT = 8443
  DBR_SUBMASK = "0x00FFFFFF"
  DBR_TCP_MAX_CONN = 10
  DBR_USE_HS_DOWNLOAD = false #Wtf does this do?
  DBR_RET_SUCCESS = 100
  DBR_SESSION_ID = "0x00000000"
  


  UNBLOCK_FIBER_DATA = "e127e855-36d2-43f1-82c0-95f2ba5fe800"
  
  # File location of the log
  LOG_LOCATION = "./xiongmai.log"

  # Open the Log
  # LOG_FILE = File.new(LOG_LOCATION, "w+")
  # LOG = Logger.new(LOG_FILE)

  # The Logger object pointed to STDOUT
  LOG = Logger.new(STDOUT)
  
  getter state : Symbol = STATES[0]

  getter db_client_sock = UDPSocket.new
  getter dbr_client_sock = UDPSocket.new
  getter data_socket = TCPSocket.new

  getter? is_running = false

  # Channel that will communicate data back to the tick fiber
  getter data_channel = Channel(Tuple(String, Socket::IPAddress)).new

  # Fiber which deals with incoming packet data, holds this data temporarily and then sends the data via @data_channel to the tick fiber.
  getter data_fiber : Fiber = spawn {}
  # Fiber which handles the decision process of handling the state of the client. receives incoming data  from data_channel and processes it
  getter tick_fiber : Fiber = spawn {} 

  # A list that hold cameras that have completed the handshake.
  getter target = Socket::IPAddress.new("0.0.0.0", 0)

  def new_target(socket_ip)
    @target = socket_ip
  end

  # Target a camera.
  def new_target(ip : String, port = 0)
    @target = Socket::IPAddress.new(ip, port)
  end
  
  # Have we found at least one target yet?
  def has_target?
    @target.port != 0
  end







  def initialize
    setup
  end

  def setup
    # Don't resetup the client if its is_running
    if !is_running?
      LOG.info("Opening ports")
      setup_ports
      LOG.info("Ports opened")
      return
    else
      LOG.error "CANNOT SETUP SERVER WHILE IT IS RUNNING!"
      raise "CANNOT SETUP SERVER WHILE IT IS RUNNING!"
    end
  end

  def setup_ports
    # Our socket for sending UDP data to the camera
    @data_sock.bind DATA_SOCK_SRC
    # Super important to enable this or else we can't broadcast to 255.255.255.255!
    @data_sock.setsockopt LibC::SO_BROADCAST, 1
    # Our socket for sending discovery broadcasts.
    @db_client_sock = UDPSocket.new
    @db_client_sock.bind DB_SOCK_CLIENT_SRC
    @db_client_sock.setsockopt LibC::SO_BROADCAST, 1
    # Our socket for sending discovery broadcasts.
    @dbr_client_sock = UDPSocket.new
    @dbr_client_sock.bind DBR_SOCK_CLIENT_SRC
    @dbr_client_sock.setsockopt LibC::SO_BROADCAST, 1
  end

  def run
    # Dont allow the client to run again!
    if !is_running?
      @is_running = true
      # Change the state so it will attempt to discover a camera on the network
      @state = :send_broadcast
      #Start our fibers
      start_data_fiber
      start_tick_fiber
    else
      LOG.error "ALREADY RUNNING SERVER!" 
    end
  end

  def close
    LOG.info("Closing client")
    sleep 0.1
    @is_running = false
    change_state(:closing)

    # This line unblocks the @data_fiber
    unblock_data
    # Force a fiber change to go to the other fibers to end them
    Fiber.yield

    # Now we can close the sockets
    @data_sock.close
    @db_client_sock.close
    @dbr_client_sock.close

    # Reset the target_camera
    new_target "0.0.0.0", 0
    change_state(:closed)

    LOG.info("Closed client")
  end

  def unblock_data
    @data_sock.send(UNBLOCK_FIBER_DATA, Socket::IPAddress.new("127.0.0.1", DATA_SOCK_SRC.port))
  end

  # Change the state of the client.
  def change_state(state)
    @state = state
    LOG.info "Changing to #{@state}"
    tick # rerun the tick since the state immeadiately changed and there is new stuff to do.
  end

  # Start the fiber which blocks for incoming data, then forwards it to a channel.
  def start_data_fiber
    @data_fiber = spawn do
      begin
        # Only run this fiber while is_running, if not exit
        while is_running?
          # Will block execution
          packet = data_sock.receive
          #LOG.info "received packet from #{packet[1]}"
          @data_channel.send(packet)
        end
      rescue e
        LOG.info "DATA EXCEPTION #{e}"
        close
      end
    end
  end

  # Start the fiber which contains the tick logic.
  def start_tick_fiber
    @tick_fiber = spawn do
      begin
        # Only run this fiber while is_running, if not exit
        while is_running?
          tick
        end
      rescue e
        LOG.info "TICK EXCEPTION #{e}"
        close
      end
    end
  end

  def tick
  end

  
  def make_dbr(gateway, host_ip, mac_address, serial_number)
  end
end