require_relative 'listener'

class CASino::TwoFactorAuthenticatorActivatorListener < CASino::Listener
  def user_not_logged_in
    @controller.redirect_to login_path
  end

  def two_factor_authenticator_activated
    @controller.flash[:notice] = I18n.t('two_factor_authenticators.successfully_activated')
    @controller.redirect_to sessions_path
  end

  def invalid_one_time_password(two_factor_authenticator)
    @controller.flash.now[:error] = I18n.t('two_factor_authenticators.invalid_one_time_password')
    assign(:two_factor_authenticator, two_factor_authenticator)
    @controller.render 'new'
  end

  def invalid_two_factor_authenticator
    @controller.flash[:error] = I18n.t('two_factor_authenticators.invalid_two_factor_authenticator')
    @controller.redirect_to new_two_factor_authenticator_path
  end
end
