module MagicError
  RESTART_ERRORS = [SocketBrokenPipe,
                    SocketConnectionRefused,
                    SocketConnectionReset,
                    SocketNoRoute,
                    LoginConnectionRefused, 
                    RecieveConnectionRefused, 
                    SendConnectionRefused, 
                    LoginBrokenPipe, 
                    RecieveBrokenPipe, 
                    SendBrokenPipe, 
                    LoginNoRoute, 
                    RecieveNoRoute, 
                    SendNoRoute, 
                    LoginConnectionReset, 
                    RecieveConnectionReset, 
                    SendConnectionReset]

  abstract class BaseException < Exception
  end

  abstract class SocketException < BaseException
  end

  abstract class LoginException < BaseException
  end

  abstract class SendException < BaseException
  end

  abstract class RecieveException < BaseException
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


  class RecieveTimeout < RecieveException
  end

  class RecieveEOF < RecieveException
  end

  class RecieveConnectionRefused < RecieveException
  end 

  class RecieveNoRoute < RecieveException
  end

  class RecieveBrokenPipe < RecieveException
  end

  class RecieveConnectionReset < RecieveException
  end
end
