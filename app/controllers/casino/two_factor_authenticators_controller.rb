require 'rotp'

class CASino::TwoFactorAuthenticatorsController < CASino::ApplicationController
  include CASino::SessionsHelper

  before_action :ensure_signed_in, only: [:new]

  def new
    @two_factor_authenticator = current_user.two_factor_authenticators.create! secret: ROTP::Base32.random_base32
  end

  def create
    processor(:TwoFactorAuthenticatorActivator).process(params, cookies, request.user_agent)
  end

  def destroy
    processor(:TwoFactorAuthenticatorDestroyer).process(params, cookies, request.user_agent)
  end
end
