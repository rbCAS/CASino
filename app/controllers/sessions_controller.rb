class SessionsController < ApplicationController
  include SessionsHelper

  def index
  end

  def new
    processor.process(params, cookies, request.user_agent)
  end

  def create
  end

  def destroy
  end

  def logout
  end

  private
  def processor
    listener = CASino::Listener::LoginCredentialRequestor.new(self)
    @processor = CASinoCore::Processor::LoginCredentialRequestor.new(listener)
  end
end
