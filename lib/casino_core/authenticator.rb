module CASinoCore
  class Authenticator
    autoload :Static, 'casino_core/authenticator/static.rb'

    def validate(username, password)
      raise NotImplementedError, "This method must be implemented by a class extending #{self.class}"
    end
  end
end
