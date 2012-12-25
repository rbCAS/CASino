require 'builder'
require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

# The ServiceTicketValidator processor should be used to handle GET requests to /serviceValidate
class CASinoCore::Processor::ServiceTicketValidator < CASinoCore::Processor
  include CASinoCore::Helper::ProxyTickets
  include CASinoCore::Helper::ProxyGrantingTickets

  # This method will call `#validation_succeeded` or `#validation_failed`. In both cases, it supplies
  # a string as argument. The web application should present that string (and nothing else) to the
  # requestor. The Content-Type should be set to 'text/xml; charset=utf-8'
  #
  # @param [Hash] params parameters delivered by the client
  def process(params = nil)
    params ||= {}
    ticket = extract_ticket_from_params(params)
    validation_result = validate_service_ticket_for_service(ticket, params[:service], !!params[:renew])
    if validation_result == true
      options = { service_ticket: ticket }
      unless params[:pgtUrl].nil?
        options[:proxy_granting_ticket] = acquire_proxy_granting_ticket(params[:pgtUrl], ticket)
      end
      @listener.validation_succeeded(build_xml(true, options))
    else
      @listener.validation_failed(build_xml(false, error_code: validation_result, error_message: 'Validation failed'))
    end
  end

  private
  def extract_ticket_from_params(params)
    if params[:ticket].nil?
      nil
    elsif params[:ticket].starts_with?('PT-')
      CASinoCore::Model::ProxyTicket.where(ticket: params[:ticket]).first
    else
      CASinoCore::Model::ServiceTicket.where(ticket: params[:ticket]).first
    end
  end
end
