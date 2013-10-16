module CASino
  class Authenticator
    class AuthenticatorError < StandardError; end

    def validate(username, password)
      raise NotImplementedError, "This method must be implemented by a class extending #{self.class}"
    end
  end
end
