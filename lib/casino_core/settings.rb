require 'casino_core/authenticator'

module CASinoCore
  class Settings
    class << self
      attr_accessor :login_ticket, :ticket_granting_ticket, :service_ticket, :proxy_ticket, :two_factor_authenticator, :authenticators, :logger, :frontend
      DEFAULT_SETTINGS = {
        login_ticket: {
          lifetime: 600
        },
        ticket_granting_ticket: {
          lifetime: 86400
        },
        service_ticket: {
          lifetime_unconsumed: 300,
          lifetime_consumed: 86400,
          single_sign_out_notification: {
            timeout: 10
          }
        },
        proxy_ticket: {
          lifetime_unconsumed: 300,
          lifetime_consumed: 86400
        },
        two_factor_authenticator: {
          lifetime_inactive: 300,
          drift: 30
        }
      }

      def init(config = {})
        DEFAULT_SETTINGS.deep_merge(config).each do |key,value|
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

      def add_defaults(name, config = {})
        DEFAULT_SETTINGS[name] = config
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
