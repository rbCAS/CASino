class CASino::SessionsController < CASino::ApplicationController
  include CASino::SessionsHelper
  include CASino::AuthenticationProcessor

  before_action :validate_login_ticket, only: [:create]
  before_action :ensure_service_allowed, only: [:new, :create]

  def index
    processor(:TwoFactorAuthenticatorOverview).process(cookies, request.user_agent)
    processor(:SessionOverview).process(cookies, request.user_agent)
  end

  def new
    tgt = current_ticket_granting_ticket
    handle_signed_in(tgt) unless params[:renew] || tgt.nil?
    redirect_to(params[:service]) if params[:gateway] && params[:service].present?
  end

  def create
    validation_result = validate_login_credentials(params[:username], params[:password])
    if !validation_result
      show_login_error I18n.t('login_credential_acceptor.invalid_login_credentials')
    else
      sign_in(validation_result, long_term: params[:rememberMe])
    end
  end

  def destroy
    processor(:SessionDestroyer).process(params, cookies, request.user_agent)
  end

  def destroy_others
    processor(:OtherSessionsDestroyer).process(params, cookies, request.user_agent)
  end

  def logout
    processor(:Logout).process(params, cookies, request.user_agent)
  end

  def validate_otp
    processor(:SecondFactorAuthenticationAcceptor).process(params, request.user_agent)
  end

  private
  def show_login_error(message)
    flash.now[:error] = message
    render :new, status: :forbidden
  end

  def validate_login_ticket
    unless CASino::LoginTicket.consume(params[:lt])
      show_login_error I18n.t('login_credential_acceptor.invalid_login_ticket')
    end
  end

  def user_logged_in(url, ticket_granting_ticket, cookie_expiry_time = nil)
    @controller.cookies[:tgt] = { value: ticket_granting_ticket, expires: cookie_expiry_time }
    if url.nil?
      @controller.redirect_to sessions_path, status: :see_other
    else
      @controller.redirect_to url, status: :see_other
    end
  end

  def two_factor_authentication_pending(ticket_granting_ticket)
    assign(:ticket_granting_ticket, ticket_granting_ticket)
    @controller.render 'validate_otp'
  end

  def invalid_login_credentials(login_ticket)
    @controller.flash.now[:error] = I18n.t('login_credential_acceptor.invalid_login_credentials')
    rerender_login_page(login_ticket)
  end

  def invalid_login_ticket(login_ticket)
    @controller.flash.now[:error] = I18n.t('login_credential_acceptor.invalid_login_ticket')
    rerender_login_page(login_ticket)
  end

  def ensure_service_allowed
    if params[:service].present? && !service_allowed?(params[:service])
      render 'service_not_allowed', status: :forbidden
    end
  end
end
