require 'rqrcode'
require 'rqrcode_png'

module CASino::TwoFactorAuthenticatorsHelper
  def otp_auth_url(two_factor_authenticator)
    "otpauth://totp/#{u CASino.config.frontend[:sso_name] + ': ' + two_factor_authenticator.user.username}?secret=#{two_factor_authenticator.secret}&issuer=#{u CASino.config.frontend[:sso_name]}"
  end

  def otp_qr_code_data_url(two_factor_authenticator)
    auth_url = otp_auth_url(two_factor_authenticator)
    size = otp_qr_code_suggested_size(auth_url)
    qr = RQRCode::QRCode.new(auth_url, size: size, level: :l)
    qr.to_img.resize(250, 250).to_data_url
  end

  def otp_qr_code_suggested_size(data)
    data_bits = data.length * 8
    (3..40).each do |size|
      metadata_bits = 4 + RQRCode::QRUtil.get_length_in_bits(RQRCode::QRMODE[:mode_8bit_byte], size)
      total_data_bits = metadata_bits + data_bits
      max_data_bits = RQRCode::QRCode.count_max_data_bits(RQRCode::QRRSBlock.get_rs_blocks(size, 1))
      return size if total_data_bits < max_data_bits
    end
  end
end
