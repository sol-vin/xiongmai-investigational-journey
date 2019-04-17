require "logger"
require "socket"



class Client
  STATES =[:send_broadcast, 
           :recieve_cameras, 
           :send_login,
           :wait_for_login_reply,
           :main_phase]

  DB = "\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xfa\x05\x00\x00\x00\x00"
  DB_CLIENT_DST = Socket::IPAddress.new("255.255.255.255", 34569)
  DB_CLIENT_SRC = Socket::IPAddress.new("0.0.0.0", 5008)
  
  DBR_CLIENT_SRC = Socket::IPAddress.new("0.0.0.0", 34569)
  
  
  getter state : Symbol = STATES[0]

  getter db_client_sock = UDPSocket.new
  getter dbr_client_sock = UDPSocket.new
  getter data_socket = TCPSocket.new

  def initialize
  end

  def setup
  end

  def setup_ports
  end

  def run
  end

  def close
  end

  def change(state)
  end

  def tick
  end








end