class SessionsController < ApplicationController
  include SessionsHelper

  def index
    processor(:SessionOverview).process(cookies, request.user_agent)
  end

  def new
    processor(:LoginCredentialRequestor).process(params, cookies, request.user_agent)
  end

  def create
    processor(:LoginCredentialAcceptor).process(params, cookies, request.user_agent)
  end

  def destroy
    processor(:SessionDestroyer).process(params, cookies, request.user_agent)
  end

  def logout
    processor(:Logout).process(params, cookies, request.user_agent)
  end
end
