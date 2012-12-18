require 'casino/listener'

class CASino::Listener::LegacyValidator < CASino::Listener
  def validation_failed(text)
    @controller.render text: text, content_type: 'text/plain'
  end

  def validation_succeeded(text)
    @controller.render text: text, content_type: 'text/plain'
  end
end
