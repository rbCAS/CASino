module CASino
  module ProcessorConcern
    module Authentication

      def validate_login_credentials(username, password)
        authentication_result = nil
        authenticators.each do |authenticator_name, authenticator|
          begin
            data = authenticator.validate(username, password)
          rescue CASino::Authenticator::AuthenticatorError => e
            Rails.logger.error "Authenticator '#{authenticator_name}' (#{authenticator.class}) raised an error: #{e}"
          end
          if data
            authentication_result = { authenticator: authenticator_name, user_data: data }
            Rails.logger.info("Credentials for username '#{data[:username]}' successfully validated using authenticator '#{authenticator_name}' (#{authenticator.class})")
            break
          end
        end
        authentication_result
      end

      def authenticators
        @authenticators ||= begin
          CASino.config.authenticators.each do |name, auth|
            next unless auth.is_a?(Hash)

            authenticator = if auth[:class]
              auth[:class].constantize
            else
              load_authenticator(auth[:authenticator])
            end

            CASino.config.authenticators[name] = authenticator.new(auth[:options])
          end
        end
      end

      private
      def load_legacy_authenticator(name)
        gemname, classname = parse_legacy_name(name)

        begin
          require gemname
          CASinoCore::Authenticator.const_get("#{classname}")
        rescue LoadError, NameError
          false
        end
      end

      def load_authenticator(name)
        legacy_authenticator = load_legacy_authenticator(name)
        return legacy_authenticator if legacy_authenticator

        gemname, classname = parse_name(name)

        begin
          require gemname
          CASino.const_get(classname)
        rescue LoadError => error
          raise LoadError, load_error_message(name, gemname, error)
        rescue NameError => error
          raise NameError, name_error_message(name, error)
        end
      end

      def parse_name(name)
        [ "casino-#{name.underscore}_authenticator", "#{name.camelize}Authenticator" ]
      end

      def parse_legacy_name(name)
        [ "casino_core-authenticator-#{name.underscore}", name.camelize ]
      end

      def load_error_message(name, gemname, error)
        "Failed to load authenticator '#{name}'. Maybe you have to include " \
        "\"gem '#{gemname}'\" in your Gemfile?\n" \
        "  Error: #{error.message}\n"
      end

      def name_error_message(name, error)
        "Failed to load authenticator '#{name}'. The authenticator class must " \
        "be defined in the CASino namespace.\n" \
        "  Error: #{error.message}\n"
      end
    end
  end
end
