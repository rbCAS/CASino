module CASinoCore
  module Helper
    module Authentication

      def validate_login_credentials(username, password)
        authentication_result = nil
        CASinoCore::Settings.authenticators.each do |authenticator_name, authenticator|
          begin
            data = authenticator.validate(username, password)
          rescue CASinoCore::Authenticator::AuthenticatorError => e
            logger.error "Authenticator '#{authenticator_name}' (#{authenticator.class}) raised an error: #{e}"
          end
          if data
            authentication_result = { authenticator: authenticator_name, user_data: data }
            logger.info("Credentials for username '#{data[:username]}' successfully validated using authenticator '#{authenticator_name}' (#{authenticator.class})")
            break
          end
        end
        authentication_result
      end

    end
  end
end
