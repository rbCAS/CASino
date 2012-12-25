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
    validation_result = validate_ticket_for_service(ticket, params[:service], !!params[:renew])
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
          unless ticket_granting_ticket.extra_attributes.blank?
            authentication_success.cas :attributes do |attributes|
              ticket_granting_ticket.extra_attributes.each do |key, value|
                serialize_extra_attribute(attributes, key, value)
              end
            end
          end
          if options[:proxy_granting_ticket]
            proxy_granting_ticket = options[:proxy_granting_ticket]
            authentication_success.cas :proxyGrantingTicket, proxy_granting_ticket.iou
          end
        end
      else
        service_response.cas :authenticationFailure, options[:error_message], code: options[:error_code]
      end
    end
    xml.target!
  end

  def serialize_extra_attribute(builder, key, value)
    if value.kind_of?(String) || value.kind_of?(Numeric) || value.kind_of?(Symbol)
      builder.cas key, "#{value}"
    elsif value.kind_of?(Numeric)
      builder.cas key, value.to_s
    else
      builder.cas key do
        builder.cdata! value.to_yaml
      end
    end
  end
end
