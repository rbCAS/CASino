class SessionsController < ApplicationController
  include SessionsHelper

  before_filter :validate_login_ticket, only: :create

  def index
    unless signed_in?
      return redirect_to new_session_path
    end
  end

  def new
    @login_ticket = acquire_login_ticket
  end

  def create
    flash[:error] = 'Incorrect username or password.'
    new
    render 'new', status: 403
  end
end
