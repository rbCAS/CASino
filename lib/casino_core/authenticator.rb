module CASinoCore
  class Authenticator
    autoload :Static, 'casino_core/authenticator/static.rb'

    class AuthenticatorError < StandardError; end

    def validate(username, password)
      raise NotImplementedError, "This method must be implemented by a class extending #{self.class}"
    end
  end
end
