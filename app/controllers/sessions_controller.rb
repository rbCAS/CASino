class SessionsController < ApplicationController
  include SessionsHelper

  def new
    @login_ticket = acquire_login_ticket
  end

  def create
    # TODO validate
  end
end
