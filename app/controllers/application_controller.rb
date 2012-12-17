require 'casino/listener'

class ApplicationController < ActionController::Base
  include ApplicationHelper

  def cookies
    super
  end
end
