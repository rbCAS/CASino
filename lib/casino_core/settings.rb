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
        @authenticators = []
        authenticators.each do |authenticator|
          unless authenticator.is_a?(CASinoCore::Authenticator)
            authenticator = authenticator[:class].constantize.new(authenticator[:options])
          end
          @authenticators << authenticator
        end
      end
    end
  end
end
