require_relative 'listener'

class CASino::TicketValidatorListener < CASino::Listener
  def validation_failed(xml)
    @controller.render xml: xml
  end

  def validation_succeeded(xml)
    @controller.render xml: xml
  end
end
