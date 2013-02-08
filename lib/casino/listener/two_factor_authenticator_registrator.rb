require 'casino/listener'

class CASino::Listener::TwoFactorAuthenticatorRegistrator < CASino::Listener
  def user_not_logged_in
    @controller.redirect_to login_path
  end

  def two_factor_authenticator_registered(two_factor_authenticator)
    assign(:two_factor_authenticator, two_factor_authenticator)
  end
end
