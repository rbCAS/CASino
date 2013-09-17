require_relative 'listener'

class CASino::TwoFactorAuthenticatorRegistratorListener < CASino::Listener
  def user_not_logged_in
    @controller.redirect_to login_path
  end

  def two_factor_authenticator_registered(two_factor_authenticator)
    assign(:two_factor_authenticator, two_factor_authenticator)
  end
end
