require_relative 'listener'

class CASino::OtherSessionsDestroyerListener < CASino::Listener
  def other_sessions_destroyed(url)
    @controller.redirect_to(url || sessions_path)
  end
end
