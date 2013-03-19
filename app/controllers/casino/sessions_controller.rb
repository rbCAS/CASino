class CASino::SessionsController < CASino::ApplicationController
  include CASino::SessionsHelper

  def index
    processor(:TwoFactorAuthenticatorOverview).process(cookies, request.user_agent)
    processor(:SessionOverview).process(cookies, request.user_agent)
  end

  def new
    processor(:LoginCredentialRequestor).process(params, cookies, request.user_agent)
  end

  def create
    processor(:LoginCredentialAcceptor).process(params, request.user_agent)
  end

  def destroy
    processor(:SessionDestroyer).process(params, cookies, request.user_agent)
  end

  def destroy_others
    processor(:OtherSessionsDestroyer).process(params, cookies, request.user_agent)
  end

  def logout
    processor(:Logout).process(params, cookies, request.user_agent)
  end

  def validate_otp
    processor(:SecondFactorAuthenticationAcceptor).process(params, request.user_agent)
  end
end
