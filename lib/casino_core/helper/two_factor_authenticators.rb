require 'addressable/uri'

module CASinoCore
  module Helper
    module TwoFactorAuthenticators
      class ValidationResult < CASinoCore::Model::ValidationResult; end

      def validate_one_time_password(user, otp, authenticator = nil)
        if authenticator.nil? || authenticator.expired? || authenticator.user_id != user.id
          ValidationResult.new 'INVALID_AUTHENTICATOR', 'Authenticator does not exist or expired', :warn
        else
          totp = ROTP::TOTP.new(authenticator.secret)
          if totp.verify_with_drift(otp, CASinoCore::Settings.two_factor_authenticator[:drift])
            ValidationResult.new
          else
            ValidationResult.new 'INVALID_OTP', 'One-time password not valid', :warn
          end
        end
      end
    end
  end
end
