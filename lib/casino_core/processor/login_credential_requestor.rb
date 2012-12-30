require 'casino_core/processor'
require 'casino_core/helper'

# This processor should be used for GET requests to /login
class CASinoCore::Processor::LoginCredentialRequestor < CASinoCore::Processor
  include CASinoCore::Helper::Browser
  include CASinoCore::Helper::Logger
  include CASinoCore::Helper::LoginTickets
  include CASinoCore::Helper::ServiceTickets
  include CASinoCore::Helper::TicketGrantingTickets

  # Use this method to process the request.
  #
  # The method will call one of the following methods on the listener:
  # * `#user_logged_in`: The first argument (String) is the URL (if any), the user should be redirected to.
  # * `#user_not_logged_in`: The first argument is a LoginTicket. It should be stored in a hidden field with name "lt".
  #
  # @param [Hash] params parameters supplied by user
  # @param [Hash] cookies cookies supplied by user
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, cookies = nil, user_agent = nil)
    params ||= {}
    cookies ||= {}
    request_env ||= {}
    if !params[:renew] && (ticket_granting_ticket = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent))
      service_url_with_ticket = unless params[:service].nil?
        acquire_service_ticket(ticket_granting_ticket, params[:service], true).service_with_ticket_url
      end
      @listener.user_logged_in(service_url_with_ticket)
    else
      if params[:gateway] == 'true' && params[:service]
        # we actually lie to the listener to simplify things
        @listener.user_logged_in(params[:service])
      else
        login_ticket = acquire_login_ticket
        @listener.user_not_logged_in(login_ticket)
      end
    end
  end
end
