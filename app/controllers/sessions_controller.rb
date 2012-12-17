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
    processor(:SessionDestroyer).process(params[:id])
  end

  def logout
    processor(:Logout).process(params, cookies)
  end

  private
  def processor(name)
    listener = CASino::Listener.const_get(name).new(self)
    @processor = CASinoCore::Processor.const_get(name).new(listener)
  end
end
