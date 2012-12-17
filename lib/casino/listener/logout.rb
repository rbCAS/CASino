require 'casino/listener'

class CASino::Listener::Logout < CASino::Listener
  def user_logged_out(url)
    assign(:url, url)
    @controller.cookies.delete :tgt
  end
end
