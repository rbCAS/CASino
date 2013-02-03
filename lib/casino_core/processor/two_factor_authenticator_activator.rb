require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

# The TwoFactorAuthenticatorActivator processor can be used to activate a previously generated two-factor authenticator.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASinoCore::Processor::TwoFactorAuthenticatorActivator < CASinoCore::Processor
  include CASinoCore::Helper::TicketGrantingTickets
  include CASinoCore::Helper::TwoFactorAuthenticators

  # This method will call `#user_not_logged_in` on the listener.
  # @param [Hash] cookies cookies delivered by the client
  # @param [String] user_agent user-agent delivered by the client
  # @param [String] id id of the two-factor authenticator
  # @param [String] otp one time password given by the user
  def process(cookies = nil, user_agent = nil, id = nil, otp = nil)
    cookies ||= {}
    tgt = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent)
    if tgt.nil?
      @listener.user_not_logged_in
    else
      authenticator = tgt.user.two_factor_authenticators.where(id: id).first
      validation_result = validate_one_time_password(tgt.user, otp, authenticator)
      if validation_result.success?
        tgt.user.two_factor_authenticators.where(active: true).delete_all
        authenticator.active = true
        authenticator.save!
        @listener.two_factor_authenticator_activated
      else
        if validation_result.error_code == 'INVALID_OTP'
          @listener.invalid_one_time_password
        else
          @listener.invalid_two_factor_authenticator
        end
      end
    end
  end
end
