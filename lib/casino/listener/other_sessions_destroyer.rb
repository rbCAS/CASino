require 'casino/listener'

class CASino::Listener::OtherSessionsDestroyer < CASino::Listener
  def other_sessions_destroyed(url)
    @controller.redirect_to(url || sessions_path)
  end
end
