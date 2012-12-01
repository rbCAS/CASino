class CASinoCore::Authenticator
  autoload :Static, 'casino_core/authenticator/static.rb'

  def self.included(authenticator)
    authenticator.extend(ClassMethods)
  end

  class ClassMethods
    def initialize(options)
    end

    def validate(username, password)
      raise NotImplementedError, "This method must be implemented by a class extending #{self.class}"
    end
  end
end
