require 'addressable/uri'

module CASino::SessionsHelper
  include CASino::TicketGrantingTicketProcessor
  include CASino::ServiceTicketProcessor

  def current_ticket_granting_ticket?(ticket_granting_ticket)
    ticket_granting_ticket.ticket == cookies[:tgt]
  end

  def current_ticket_granting_ticket
    return nil unless cookies[:tgt]
    return @current_ticket_granting_ticket unless @current_ticket_granting_ticket.nil?
    find_valid_ticket_granting_ticket(cookies[:tgt], request.user_agent).tap do |tgt|
      cookies.delete :tgt if tgt.nil?
      @current_ticket_granting_ticket = tgt
    end
  end

  def current_user
    tgt = current_ticket_granting_ticket
    return nil if tgt.nil?
    tgt.user
  end

  def ensure_signed_in
    redirect_to login_path unless signed_in?
  end

  def signed_in?
    !current_ticket_granting_ticket.nil?
  end

  def sign_in(authentication_result, options = {})
    tgt = acquire_ticket_granting_ticket(authentication_result, request.user_agent, request.remote_ip, options)
    set_tgt_cookie(tgt)
    handle_signed_in(tgt, options)
  end

  def set_tgt_cookie(tgt)
    cookies[:tgt] = { value: tgt.ticket }.tap do |cookie|
      if tgt.long_term?
        cookie[:expires] = CASino.config.ticket_granting_ticket[:lifetime_long_term].seconds.from_now
      end
    end
  end

  def sign_out
    remove_ticket_granting_ticket(cookies[:tgt], request.user_agent)
    cookies.delete :tgt
  end

  private
  def handle_signed_in(tgt, options = {})
    if tgt.awaiting_two_factor_authentication?
      @ticket_granting_ticket = tgt
      render 'casino/sessions/validate_otp'
    else
      if params[:service].present?
        begin
          handle_signed_in_with_service(tgt, options)
          return
        rescue Addressable::URI::InvalidURIError => e
          Rails.logger.warn "Service #{params[:service]} not valid: #{e}"
        end
      end
      redirect_to sessions_path, status: :see_other
    end
  end

  def handle_signed_in_with_service(tgt, options)
    if !service_allowed?(params[:service])
      @service = params[:service]
      render 'casino/sessions/service_not_allowed', status: 403
    else
      url = acquire_service_ticket(tgt, params[:service], options).service_with_ticket_url
      redirect_to url, status: :see_other
    end
  end
end
