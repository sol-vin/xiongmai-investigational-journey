module XMError

  abstract class Exception < ::Exception
  end

  abstract class SocketException < Exception
  end

  abstract class LoginException < Exception
  end

  abstract class SendException < Exception
  end

  abstract class ReceiveException < Exception
  end



  class SocketConnectionRefused < SocketException
  end 

  class SocketNoRoute < SocketException
  end

  class SocketBrokenPipe < SocketException
  end
    
  class SocketConnectionReset < SocketException
  end


  class LoginTimeout < LoginException
  end

  class LoginEOF < LoginException
  end

  class LoginFailure < LoginException
  end

  class LoginConnectionRefused < LoginException
  end
  
  class LoginNoRoute < LoginException
  end

  class LoginBrokenPipe < LoginException
  end

  class LoginConnectionReset < LoginException
  end

  class LoginBadFileDescriptor < LoginException
  end

  
  class SendTimeout < SendException
  end

  class SendEOF < SendException
  end

  class SendConnectionRefused < SendException
  end 

  class SendNoRoute < SendException
  end

  class SendBrokenPipe < SendException
  end
    
  class SendConnectionReset < SendException
  end

  class SendBadFileDescriptor < SendException
  end


  class ReceiveTimeout < ReceiveException
  end

  class ReceiveEOF < ReceiveException
  end

  class ReceiveConnectionRefused < ReceiveException
  end 

  class ReceiveNoRoute < ReceiveException
  end

  class ReceiveBrokenPipe < ReceiveException
  end

  class ReceiveConnectionReset < ReceiveException
  end

  class ReceiveBadFileDescriptor < ReceiveException
  end
end
