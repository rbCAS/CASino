require 'casino/listener'

class CASino::Listener::SessionDestroyer < CASino::Listener
  def ticket_deleted
    @controller.redirect_to(sessions_path)
  end

  def ticket_not_found
    @controller.redirect_to(sessions_path)
  end
end
