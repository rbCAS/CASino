require 'builder'
require 'casino_core/builder'

class CASinoCore::Builder::ServiceResponse < CASinoCore::Builder
  def initialize(success, options)
    @success = success
    @options = options
  end

  def build
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.cas :serviceResponse, 'xmlns:cas' => 'http://www.yale.edu/tp/cas' do |service_response|
      if @success
        ticket_granting_ticket = @options[:ticket].ticket_granting_ticket
        service_response.cas :authenticationSuccess do |authentication_success|
          authentication_success.cas :user, ticket_granting_ticket.username
          unless ticket_granting_ticket.extra_attributes.blank?
            authentication_success.cas :attributes do |attributes|
              ticket_granting_ticket.extra_attributes.each do |key, value|
                serialize_extra_attribute(attributes, key, value)
              end
            end
          end
          if @options[:proxy_granting_ticket]
            proxy_granting_ticket = @options[:proxy_granting_ticket]
            authentication_success.cas :proxyGrantingTicket, proxy_granting_ticket.iou
          end
        end
      else
        service_response.cas :authenticationFailure, @options[:error_message], code: @options[:error_code]
      end
    end
    xml.target!
  end

  private
  def serialize_extra_attribute(builder, key, value)
    if value.kind_of?(String) || value.kind_of?(Numeric) || value.kind_of?(Symbol)
      builder.cas key, "#{value}"
    elsif value.kind_of?(Numeric)
      builder.cas key, value.to_s
    else
      builder.cas key do |container|
        container.cdata! value.to_yaml
      end
    end
  end
end
