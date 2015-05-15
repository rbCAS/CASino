require 'builder'

class CASino::ProxyResponseBuilder
  attr_reader :success, :options

  def initialize(success, options)
    @success = success
    @options = options
  end

  def build
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
