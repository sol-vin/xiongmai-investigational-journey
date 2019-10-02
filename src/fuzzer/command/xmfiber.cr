class XMFiber
  property state : String = ""
  property fiber : Fiber = spawn {}
  property check_in : Time = Time.new(1970, 1, 1, 0, 0, 0)

  def check_in
    @check_in = Time.now
  end
end