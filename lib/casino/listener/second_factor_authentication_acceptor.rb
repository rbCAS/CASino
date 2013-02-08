require 'casino/listener'

class CASino::Listener::SecondFactorAuthenticationAcceptor < CASino::Listener

  def user_not_logged_in
    @controller.redirect_to login_path
  end

  def user_logged_in(url, ticket_granting_ticket)
    @controller.cookies[:tgt] = ticket_granting_ticket
    if url.nil?
      @controller.redirect_to sessions_path, status: :see_other
    else
      @controller.redirect_to url, status: :see_other
    end
  end

  def invalid_one_time_password
    @controller.flash.now[:error] = I18n.t('validate_otp.invalid_otp')
  end

  def service_not_allowed(service)
    assign(:service, service)
    @controller.render 'service_not_allowed', status: 403
  end
end
