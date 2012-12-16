require 'casino/authenticator'

class SessionsController < ApplicationController
  include SessionsHelper

  before_filter :validate_login_ticket, only: :create
  before_filter :authenticate, only: :index

  def index
  end

  def new
  end

  def create
  end

  def destroy
  end

  def logout
  end
end
