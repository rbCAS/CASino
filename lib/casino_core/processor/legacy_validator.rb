require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

# The LegacyValidator processor should be used for GET requests to /validate
class CASinoCore::Processor::LegacyValidator < CASinoCore::Processor
  include CASinoCore::Helper::Logger
  include CASinoCore::Helper::ServiceTickets

  # This method will call `#validation_succeeded` or `#validation_failed`. In both cases, it supplies
  # a string as argument. The web application should present that string (and nothing else) to the
  # requestor.
  #
  # @param [Hash] params parameters supplied by requestor (a service)
  def process(params = nil)
    params ||= {}
    ticket = CASinoCore::Model::ServiceTicket.where(ticket: params[:ticket]).first
    if service_ticket_valid_for_service?(ticket, params[:service], !!params[:renew])
      @listener.validation_succeeded("yes\n#{ticket.ticket_granting_ticket.username}\n")
    else
      @listener.validation_failed("no\n\n")
    end
  end
end
