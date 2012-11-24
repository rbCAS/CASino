module CASino
  module Authenticator
    class Base
      def initialize(options)
      end

      def validate(username, password)
        raise NotImplementedError, "This method must be implemented by a class extending #{self.class}"
      end
    end
  end
end
