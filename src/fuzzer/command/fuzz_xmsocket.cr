class FuzzXMSocketTCP < XMSocketTCP
  property uuid : UUID = UUID.random
  property state : String = ""
  property log : String = ""
  property command : UInt16 = 0_u16
  property timeout_counter : Time = Time.now
  getter wait_channel = Channel(Nil).new
  getter manage_channel = Channel(Nil).new
end