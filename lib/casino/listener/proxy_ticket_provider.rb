require 'casino/listener'

class CASino::Listener::ProxyTicketProvider < CASino::Listener
  def request_failed(xml)
    @controller.render xml: xml
  end

  def request_succeeded(xml)
    @controller.render xml: xml
  end
end
