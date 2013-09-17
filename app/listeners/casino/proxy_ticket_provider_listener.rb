require_relative 'listener'

class CASino::ProxyTicketProviderListener < CASino::Listener
  def request_failed(xml)
    @controller.render xml: xml
  end

  def request_succeeded(xml)
    @controller.render xml: xml
  end
end
