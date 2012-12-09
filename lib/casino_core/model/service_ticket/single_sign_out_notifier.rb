require 'builder'
require 'net/https'
require 'casino_core/model/service_ticket'

class CASinoCore::Model::ServiceTicket::SingleSignOutNotifier
  def initialize(service_ticket)
    @service_ticket = service_ticket
  end

  def notify
    xml = build_xml
    uri = URI.parse(@service_ticket.service)
    request = build_request(uri, xml)
    send_notification(uri, request)
  end

  private
  def build_xml
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.samlp :LogoutRequest, ID: SecureRandom.uuid, Version: '2.0', IsseInstant: Time.now do |logout_request|
      logout_request.samlp :NameID, '@NOT_USED@'
      logout_request.samlp :SessionIndex, @service_ticket.ticket
    end
    xml.target!
  end

  def build_request(uri, xml)
    request = Net::HTTP::Post.new(uri.path || '/')
    request.set_form_data(logoutRequest: xml)
    return request
  end

  def send_notification(uri, request)
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
    rescue Exception => e
      logger.warn "Failed to send logout notification to service #{uri} due to #{e}"
      return false
    end
  end
end
