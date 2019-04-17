module MagicError
  ALL_ERRORS = LOGIN_ERRORS + SEND_ERRORS + RECIEVE_ERRORS

  LOGIN_ERRORS = [LoginConnectionRefused, 
                  LoginEOF, 
                  LoginFailure, 
                  LoginNoRoute, 
                  LoginTimeout, 
                  LoginBrokenPipe,
                  LoginConnectionReset]

  SEND_ERRORS = [SendConnectionRefused, 
                 SendEOF, 
                 SendNoRoute, 
                 SendTimeout, 
                 SendBrokenPipe,
                 SendConnectionReset]
                 
  RECIEVE_ERRORS = [RecieveConnectionRefused, 
                    RecieveEOF, 
                    RecieveNoRoute, 
                    RecieveTimeout, 
                    RecieveBrokenPipe,
                    RecieveConnectionReset]

  RESTART_ERRORS = [LoginConnectionRefused, 
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

  class LoginTimeout < Exception
  end

  class LoginEOF < Exception
  end

  class LoginFailure < Exception
  end

  class LoginConnectionRefused < Exception
  end
  
  class LoginNoRoute < Exception
  end

  class LoginBrokenPipe < Exception
  end

  class LoginConnectionReset < Exception
  end

  
  class SendTimeout < Exception
  end

  class SendEOF < Exception
  end

  class SendConnectionRefused < Exception
  end 

  class SendNoRoute < Exception
  end

  class SendBrokenPipe < Exception
  end
    
  class SendConnectionReset < Exception
  end


  class RecieveTimeout < Exception
  end

  class RecieveEOF < Exception
  end

  class RecieveConnectionRefused < Exception
  end 

  class RecieveNoRoute < Exception
  end

  class RecieveBrokenPipe < Exception
  end

  class RecieveConnectionReset < Exception
  end
end
