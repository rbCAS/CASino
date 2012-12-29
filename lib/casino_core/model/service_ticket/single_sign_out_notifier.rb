require 'builder'
require 'net/https'
require 'casino_core/model/service_ticket'
require 'addressable/uri'

class CASinoCore::Model::ServiceTicket::SingleSignOutNotifier
  include CASinoCore::Helper::Logger

  def initialize(service_ticket)
    @service_ticket = service_ticket
  end

  def notify
    xml = build_xml
    uri = Addressable::URI.parse(@service_ticket.service)
    request = build_request(uri, xml)
    send_notification(uri, request)
  end

  private
  def build_xml
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.samlp :LogoutRequest,
      'xmlns:samlp' => 'urn:oasis:names:tc:SAML:2.0:protocol',
      'xmlns:saml' => 'urn:oasis:names:tc:SAML:2.0:assertion',
      ID: SecureRandom.uuid,
      Version: '2.0',
      IssueInstant: Time.now do |logout_request|
      logout_request.saml :NameID, '@NOT_USED@'
      logout_request.samlp :SessionIndex, @service_ticket.ticket
    end
    xml.target!
  end

  def build_request(uri, xml)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(logoutRequest: xml)
    return request
  end

  def send_notification(uri, request)
    logger.info "Sending Single Sign Out notification for ticket '#{@service_ticket.ticket}'"
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme =='https'

      http.start do |conn|
        response = conn.request(request)
        if response.kind_of? Net::HTTPSuccess
          logger.info "Logout notification successfully posted to #{uri}."
          return true
        else
          logger.warn "Service #{uri} responed to logout notification with code '#{response.code}'!"
          return false
        end
      end
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      logger.warn "Failed to send logout notification to service #{uri} due to #{e}"
      return false
    end
  end
end
