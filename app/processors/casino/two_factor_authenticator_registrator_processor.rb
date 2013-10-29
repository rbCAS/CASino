require 'rotp'

# The TwoFactorAuthenticatorRegistrator processor can be used as the first step to register a new two-factor authenticator.
# It is inactive until activated using TwoFactorAuthenticatorActivator.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASino::TwoFactorAuthenticatorRegistratorProcessor < CASino::Processor
  include CASino::ProcessorConcern::TicketGrantingTickets

  # This method will call `#user_not_logged_in` or `#two_factor_authenticator_registered(two_factor_authenticator)` on the listener.
  # @param [Hash] cookies cookies delivered by the client
  # @param [String] user_agent user-agent delivered by the client
  def process(cookies = nil, user_agent = nil)
    cookies ||= {}
    tgt = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent)
    if tgt.nil?
      @listener.user_not_logged_in
    else
      two_factor_authenticator = tgt.user.two_factor_authenticators.create! secret: ROTP::Base32.random_base32
      @listener.two_factor_authenticator_registered(two_factor_authenticator)
    end
  end
end
