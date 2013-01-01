require 'casino_core/authenticator'

module CASinoCore
  class Settings
    class << self
      attr_accessor :login_ticket, :service_ticket, :proxy_ticket, :authenticators, :logger
      def init(config = {})
        config.each do |key,value|
          if respond_to?("#{key}=")
            send("#{key}=", value)
          end
        end
      end

      def logger
        @logger ||= ::Logger.new(STDOUT)
      end

      def authenticators=(authenticators)
        @authenticators = {}
        authenticators.each do |index, authenticator|
          unless authenticator.is_a?(CASinoCore::Authenticator)
            if authenticator[:class]
              authenticator = authenticator[:class].constantize.new(authenticator[:options])
            else
              authenticator = load_and_instantiate_authenticator(authenticator[:authenticator], authenticator[:options])
            end
          end
          @authenticators[index] = authenticator
        end
      end

      private
      def load_and_instantiate_authenticator(name, options)
        gemname = "casino_core-authenticator-#{name.underscore}"
        classname = name.classify
        begin
          require gemname
          CASinoCore::Authenticator.const_get(classname).new(options)
        rescue LoadError
          raise LoadError, "Authenticator '#{name}' not found. Please include \"gem '#{gemname}'\" in your Gemfile and try again."
        end
      end
    end
  end
end
