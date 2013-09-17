require_relative 'listener'

class CASino::SessionDestroyerListener < CASino::Listener
  def ticket_deleted
    @controller.redirect_to(sessions_path)
  end

  def ticket_not_found
    @controller.redirect_to(sessions_path)
  end
end
