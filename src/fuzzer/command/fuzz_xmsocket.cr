class FuzzXMSocketTCP < XMSocketTCP
  property uuid : UUID = UUID.random
  property state : Symbol = :none
  property log : String = ""
  property command : UInt16 = 0_u16
  property timeout : Time = Time.now
  getter wait_channel = Channel(Nil).new
  getter manage_channel = Channel(Nil).new
  property manage_state : Symbol = :none
end