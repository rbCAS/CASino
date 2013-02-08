class CASino::TwoFactorAuthenticatorsController < CASino::ApplicationController
  include CASino::SessionsHelper

  def new
    processor(:TwoFactorAuthenticatorRegistrator).process(cookies, request.user_agent)
  end

  def create
    processor(:TwoFactorAuthenticatorActivator).process(params, cookies, request.user_agent)
  end

  def destroy
    processor(:TwoFactorAuthenticatorDestroyer).process(params, cookies, request.user_agent)
  end
end
