require 'casino/listener'

class CASino::Listener::LoginCredentialAcceptor < CASino::Listener
  def user_logged_in(url)
    if url.nil?
      @controller.redirect_to sessions_path, status: :see_other
    else
      @controller.redirect_to url, status: :see_other
    end
  end
end
