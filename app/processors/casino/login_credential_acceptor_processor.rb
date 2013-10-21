# This processor should be used for POST requests to /login
class CASino::LoginCredentialAcceptorProcessor < CASino::Processor
  include CASino::ProcessorConcern::LoginTickets
  include CASino::ProcessorConcern::ServiceTickets
  include CASino::ProcessorConcern::Authentication
  include CASino::ProcessorConcern::TicketGrantingTickets

  # Use this method to process the request. It expects the username in the parameter "username" and the password
  # in "password".
  #
  # The method will call one of the following methods on the listener:
  # * `#user_logged_in`: The first argument (String) is the URL (if any), the user should be redirected to.
  #   The second argument (String) is the ticket-granting ticket. It should be stored in a cookie named "tgt".
  #   The third argument (Time, optional, default = nil) is for "Remember Me" functionality.
  #   This is the cookies expiration date. If it is `nil`, the cookie should be a session cookie.
  # * `#invalid_login_ticket` and `#invalid_login_credentials`: The first argument is a LoginTicket.
  #   See {CASino::LoginCredentialRequestorProcessor} for details.
  # * `#service_not_allowed`: The user tried to access a service that this CAS server is not allowed to serve.
  # * `#two_factor_authentication_pending`: The user should be asked to enter his OTP. The first argument (String) is the ticket-granting ticket. The ticket-granting ticket is not active yet. Use SecondFactorAuthenticatonAcceptor to activate it.
  #
  # @param [Hash] params parameters supplied by user
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, user_agent = nil)
    @params = params || {}
    @user_agent = user_agent
    if login_ticket_valid?(@params[:lt])
      authenticate_user
    else
      @listener.invalid_login_ticket(acquire_login_ticket)
    end
  end

  private
  def authenticate_user
    authentication_result = validate_login_credentials(@params[:username], @params[:password])
    if !authentication_result.nil?
      user_logged_in(authentication_result)
    else
      @listener.invalid_login_credentials(acquire_login_ticket)
    end
  end

  def user_logged_in(authentication_result)
    long_term = @params[:rememberMe]
    ticket_granting_ticket = acquire_ticket_granting_ticket(authentication_result, @user_agent, long_term)
    if ticket_granting_ticket.awaiting_two_factor_authentication?
      @listener.two_factor_authentication_pending(ticket_granting_ticket.ticket)
    else
      begin
        url = unless @params[:service].blank?
          acquire_service_ticket(ticket_granting_ticket, @params[:service], true).service_with_ticket_url
        end
        if long_term
          @listener.user_logged_in(url, ticket_granting_ticket.ticket, CASino.config.ticket_granting_ticket[:lifetime_long_term].seconds.from_now)
        else
          @listener.user_logged_in(url, ticket_granting_ticket.ticket)
        end
      rescue ServiceNotAllowedError => e
        @listener.service_not_allowed(clean_service_url @params[:service])
      end
    end
  end
end
