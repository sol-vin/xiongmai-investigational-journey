require "logger"
require "socket"

DB = "\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xfa\x05\x00\x00\x00\x00"
DB_CLIENT_DST = Socket::IPAddress.new("255.255.255.255", 34569)
DB_CLIENT_SRC = Socket::IPAddress.new("0.0.0.0", 5008)

DBR_CLIENT_SRC = Socket::IPAddress.new("0.0.0.0", 34569)


db_client_sock = UDPSocket.new
db_client_sock.bind DB_CLIENT_SRC
db_client_sock.setsockopt LibC::SO_BROADCAST, 1

dbr_client_sock = UDPSocket.new
dbr_client_sock.bind DBR_CLIENT_SRC
dbr_client_sock.setsockopt LibC::SO_BROADCAST, 1

db_client_sock.send(DB, DB_CLIENT_DST)
pp dbr_client_sock.receive[0]
pp dbr_client_sock.receive[0]