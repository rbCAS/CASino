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

  def sign_in(authentication_result, options = {})
    tgt = acquire_ticket_granting_ticket(authentication_result, request.user_agent, options.slice(:long_term))
    handle_signed_in(tgt, options)
  end

  private
  def handle_signed_in(tgt, options = {})
    if !options[:skip_two_factor] && tgt.awaiting_two_factor_authentication?
      @ticket_granting_ticket = tgt
      render 'casino/sessions/validate_otp'
    else
      cookies[:tgt] = { value: tgt.ticket }.tap do |cookie|
        cookie[:expires] = CASino.config.ticket_granting_ticket[:lifetime_long_term].seconds.from_now
      end
      if params[:service].present?
        begin
          handle_signed_in_with_service(tgt)
          return
        rescue Addressable::URI::InvalidURIError => e
          Rails.logger.warn "Service #{params[:service]} not valid: #{e}"
        end
      end
      redirect_to controller: 'casino/sessions', action: :index, status: :see_other
    end
  end

  def handle_signed_in_with_service(tgt)
    if !service_allowed?(params[:service])
      @service = params[:service]
      render 'casino/sessions/service_not_allowed', status: 403
    else
      url = acquire_service_ticket(tgt, params[:service], credentials_supplied: true).service_with_ticket_url
      redirect_to url, status: :see_other
    end
  end
end
