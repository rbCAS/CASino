require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

# The Logout processor should be used to process GET requests to /logout.
class CASinoCore::Processor::Logout < CASinoCore::Processor
  include CASinoCore::Helper::TicketGrantingTickets

  # This method will call `#user_logged_out` and may supply an URL that should be presented to the user.
  # As per specification, the URL specified by "url" SHOULD be on the logout page with descriptive text.
  # For example, "The application you just logged out of has provided a link it would like you to follow.
  # Please click here to access http://www.go-back.edu/."
  #
  # @param [Hash] params parameters supplied by user
  # @param [Hash] cookies cookies supplied by user
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, cookies = nil, user_agent = nil)
    params ||= {}
    cookies ||= {}
    remove_ticket_granting_ticket(cookies[:tgt], user_agent)
    @listener.user_logged_out(params[:url])
  end
end
