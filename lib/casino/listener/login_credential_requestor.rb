require 'casino/listener'

class CASino::Listener::LoginCredentialRequestor < CASino::Listener
  def user_not_logged_in(login_ticket)
    assign(:login_ticket, login_ticket)
  end
end
