module CASino::TwoFactorAuthenticatorsHelper
  def otp_auth_url(two_factor_authenticator)
    "otpauth://totp/#{u CASino.config.frontend[:sso_name] + ': ' + two_factor_authenticator.user.username}?secret=#{two_factor_authenticator.secret}&issuer=#{u CASino.config.frontend[:sso_name]}"
  end
end
