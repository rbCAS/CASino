# The TwoFactorAuthenticatorActivator processor can be used to activate a previously generated two-factor authenticator.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASino::TwoFactorAuthenticatorActivatorProcessor < CASino::Processor
  include CASino::ProcessorConcern::TicketGrantingTickets
  include CASino::ProcessorConcern::TwoFactorAuthenticators

  # The method will call one of the following methods on the listener:
  # * `#user_not_logged_in`: The user is not logged in and should be redirected to /login.
  # * `#two_factor_authenticator_activated`: The two-factor authenticator was successfully activated.
  # * `#invalid_two_factor_authenticator`: The two-factor authenticator is not valid.
  # * `#invalid_one_time_password`: The user should be asked for a new OTP.
  #
  # @param [Hash] params parameters supplied by user. The processor will look for keys :otp and :id.
  # @param [Hash] cookies cookies delivered by the client
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, cookies = nil, user_agent = nil)
    cookies ||= {}
    params ||= {}
    tgt = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent)
    if tgt.nil?
      @listener.user_not_logged_in
    else
      authenticator = tgt.user.two_factor_authenticators.where(id: params[:id]).first
      validation_result = validate_one_time_password(params[:otp], authenticator)
      if validation_result.success?
        tgt.user.two_factor_authenticators.where(active: true).delete_all
        authenticator.active = true
        authenticator.save!
        @listener.two_factor_authenticator_activated
      else
        if validation_result.error_code == 'INVALID_OTP'
          @listener.invalid_one_time_password(authenticator)
        else
          @listener.invalid_two_factor_authenticator
        end
      end
    end
  end
end
