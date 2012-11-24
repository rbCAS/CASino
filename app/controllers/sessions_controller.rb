require 'casino/authenticator'

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
    unless validate(params[:session][:username], params[:session][:password])
      flash[:error] = 'Incorrect username or password.'
      new
      render 'new', status: 403
    else
      # TODO write user data to session
      redirect_to sessions_path
    end
  end

  private
  def validate(username, password)
    user_data = nil
    Yetting.authenticators.each do |authenticator|
      instance = "#{authenticator['class']}".constantize.new(authenticator['options'])
      data = instance.validate(username, password)
      if data
        if data['username'].nil?
          data['username'] = username
        end
        user_data = data
        break
      end
    end
    user_data
  end
end
