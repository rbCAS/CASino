# The SecondFactorAuthenticationAcceptor processor can be used to activate a previously generated ticket-granting ticket with pending two-factor authentication.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASino::SecondFactorAuthenticationAcceptorProcessor < CASino::Processor
  include CASino::ProcessorConcern::ServiceTickets
  include CASino::ProcessorConcern::TicketGrantingTickets
  include CASino::ProcessorConcern::TwoFactorAuthenticators

  # The method will call one of the following methods on the listener:
  # * `#user_not_logged_in`: The user should be redirected to /login.
  # * `#user_logged_in`: The first argument (String) is the URL (if any), the user should be redirected to.
  #   The second argument (String) is the ticket-granting ticket. It should be stored in a cookie named "tgt".
  # * `#invalid_one_time_password`: The user should be asked for a new OTP.
  #
  # @param [Hash] params parameters supplied by user. The processor will look for keys :otp and :service.
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, user_agent = nil)
    cookies ||= {}
    tgt = find_valid_ticket_granting_ticket(params[:tgt], user_agent, true)
    if tgt.nil?
      @listener.user_not_logged_in
    else
      validation_result = validate_one_time_password(params[:otp], tgt.user.active_two_factor_authenticator)
      if validation_result.success?
        tgt.awaiting_two_factor_authentication = false
        tgt.save!
        begin
          url = unless params[:service].blank?
            acquire_service_ticket(tgt, params[:service], true).service_with_ticket_url
          end
          if tgt.long_term?
            @listener.user_logged_in(url, tgt.ticket, CASino.config.ticket_granting_ticket[:lifetime_long_term].seconds.from_now)
          else
            @listener.user_logged_in(url, tgt.ticket)
          end
        rescue ServiceNotAllowedError => e
          @listener.service_not_allowed(clean_service_url params[:service])
        end
      else
        @listener.invalid_one_time_password
      end
    end
  end
end
