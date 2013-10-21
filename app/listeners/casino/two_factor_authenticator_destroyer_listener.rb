require_relative 'listener'

class CASino::TwoFactorAuthenticatorDestroyerListener < CASino::Listener
  def user_not_logged_in
    @controller.redirect_to login_path
  end

  def two_factor_authenticator_destroyed
    @controller.flash[:notice] = I18n.t('two_factor_authenticators.successfully_deleted')
    @controller.redirect_to sessions_path
  end

  def invalid_two_factor_authenticator
    @controller.redirect_to sessions_path
  end
end
