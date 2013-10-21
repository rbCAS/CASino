require 'builder'

# The ProxyTicketProvider processor should be used to handle GET requests to /proxy
class CASino::ProxyTicketProviderProcessor < CASino::Processor
  include CASino::ProcessorConcern::ProxyGrantingTickets
  include CASino::ProcessorConcern::ProxyTickets

  # This method will call `#request_succeeded` or `#request_failed`. In both cases, it supplies
  # a string as argument. The web application should present that string (and nothing else) to the
  # requestor. The Content-Type should be set to 'text/xml; charset=utf-8'
  #
  # @param [Hash] params parameters delivered by the client
  def process(params = nil)
    if params[:pgt].nil? || params[:targetService].nil?
      @listener.request_failed build_xml false, error_code: 'INVALID_REQUEST', error_message: '"pgt" and "targetService" parameters are both required'
    else
      proxy_granting_ticket = CASino::ProxyGrantingTicket.where(ticket: params[:pgt]).first
      if proxy_granting_ticket.nil?
        @listener.request_failed build_xml false, error_code: 'BAD_PGT', error_message: 'PGT not found'
      else
        proxy_ticket = acquire_proxy_ticket(proxy_granting_ticket, params[:targetService])
        @listener.request_succeeded build_xml true, proxy_ticket: proxy_ticket
      end
    end
  end

  private
  def build_xml(success, options = {})
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.cas :serviceResponse, 'xmlns:cas' => 'http://www.yale.edu/tp/cas' do |service_response|
      if success
        service_response.cas :proxySuccess do |proxy_success|
          proxy_success.cas :proxyTicket, options[:proxy_ticket].ticket
        end
      else
        service_response.cas :proxyFailure, options[:error_message], code: options[:error_code]
      end
    end
    xml.target!
  end
end
