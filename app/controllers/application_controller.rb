require 'casino/listener'

class ApplicationController < ActionController::Base
  include ApplicationHelper

  def cookies
    super
  end

  protected
  def processor(name)
    listener = CASino::Listener.const_get(name).new(self)
    @processor = CASinoCore::Processor.const_get(name).new(listener)
  end
end
