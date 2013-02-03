require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

# The TwoFactorAuthenticatorProvider processor can be used as the first step to register a new two-factor authenticator.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASinoCore::Processor::TwoFactorAuthenticatorProvider < CASinoCore::Processor
  include CASinoCore::Helper::TicketGrantingTickets

  # This method will call `#user_not_logged_in` or `#ticket_granting_tickets_found(Enumerable)` on the listener.
  # @param [Hash] cookies cookies delivered by the client
  # @param [String] user_agent user-agent delivered by the client
  def process(cookies = nil, user_agent = nil)
    cookies ||= {}
    tgt = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent)
    if tgt.nil?
      @listener.user_not_logged_in
    else
      two_factor_authenticator = tgt.user.two_factor_authenticators.create! secret: ROTP::Base32.random_base32
      @listener.two_factor_authenticator_created(two_factor_authenticator)
    end
  end
end
