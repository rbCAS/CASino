require 'casino/listener'

class CASino::Listener::LoginCredentialRequestor < CASino::Listener
  def user_not_logged_in(login_ticket)
    assign(:login_ticket, login_ticket)
    @controller.cookies.delete :tgt
  end

  def user_logged_in(url)
    if url.nil?
      @controller.redirect_to sessions_path
    else
      @controller.redirect_to url, status: :see_other
    end
  end
end
