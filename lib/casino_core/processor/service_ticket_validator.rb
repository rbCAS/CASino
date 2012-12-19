require 'builder'
require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

# The ServiceTicketValidator processor should be used to handle GET requests to /serviceValidate
class CASinoCore::Processor::ServiceTicketValidator < CASinoCore::Processor
  include CASinoCore::Helper::ServiceTickets
  include CASinoCore::Helper::ProxyGrantingTickets

  # This method will call `#validation_succeeded` or `#validation_failed`. In both cases, it supplies
  # a string as argument. The web application should present that string (and nothing else) to the
  # requestor. The Content-Type should be set to 'text/xml; charset=utf-8'
  #
  # @param [Hash] params parameters delivered by the client
  def process(params = nil)
    params ||= {}
    ticket = CASinoCore::Model::ServiceTicket.where(ticket: params[:ticket]).first
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
  def build_xml(success, options = {})
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.cas :serviceResponse, 'xmlns:cas' => 'http://www.yale.edu/tp/cas' do |service_response|
      if success
        ticket_granting_ticket = options[:service_ticket].ticket_granting_ticket
        service_response.cas :authenticationSuccess do |authentication_success|
          authentication_success.cas :user, ticket_granting_ticket.username
        end
      else
        service_response.cas :authenticationFailure, options[:error_message], code: options[:error_code]
      end
    end
    xml.target!
  end
end
