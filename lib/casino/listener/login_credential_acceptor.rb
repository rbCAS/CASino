require 'casino/listener'

class CASino::Listener::LoginCredentialAcceptor < CASino::Listener
  def user_logged_in(url)
    if url.nil?
      @controller.redirect_to sessions_path, status: :see_other
    else
      @controller.redirect_to url, status: :see_other
    end
  end

  def invalid_login_credentials(login_ticket)
    @controller.flash.now[:error] = I18n.t('login_credential_acceptor.invalid_login_credentials')
    rerender_login_page(login_ticket)
  end

  def invalid_login_ticket(login_ticket)
    @controller.flash.now[:error] = I18n.t('login_credential_acceptor.invalid_login_ticket')
    rerender_login_page(login_ticket)
  end

  private
  def rerender_login_page(login_ticket)
    assign(:login_ticket, login_ticket)
    @controller.render 'new', status: 403
  end
end
