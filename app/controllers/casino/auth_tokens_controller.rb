class CASino::AuthTokensController < CASino::ApplicationController
  include CASino::SessionsHelper

  def login
    validation_result = validation_service.validation_result
    return redirect_to_login unless validation_result
    sign_in(validation_result)
  end

  private
  def validation_service
    @validation_service ||= CASino::AuthTokenValidationService.new(auth_token, auth_token_signature)
  end

  def redirect_to_login
    redirect_to login_path(service: params[:service])
  end

  def auth_token_signature
    @auth_token_signature ||= base64_decode(params[:ats])
  end

  def auth_token
    @auth_token ||= base64_decode(params[:at])
  end

  def base64_decode(data)
    begin
      Base64.strict_decode64(data)
    rescue
      ''
    end
  end
end
