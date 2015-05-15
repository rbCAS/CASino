require 'rqrcode_png'

module CASino::TwoFactorAuthenticatorsHelper
  def otp_auth_url(two_factor_authenticator)
    "otpauth://totp/#{u CASino.config.frontend[:sso_name] + ': ' + two_factor_authenticator.user.username}?secret=#{two_factor_authenticator.secret}&issuer=#{u CASino.config.frontend[:sso_name]}"
  end

  def otp_qr_code_data_url(two_factor_authenticator)
    qr = RQRCode::QRCode.new(otp_auth_url(two_factor_authenticator), size: 5, level: :l)
    qr.to_img.resize(250,250).to_data_url
  end
end
