require 'casino/listener'
require 'casino_core'

class ApplicationController < ActionController::Base
  include ApplicationHelper

  def cookies
    super
  end

  protected
  def processor(processor_name, listener_name = nil)
    listener_name ||= processor_name
    listener = CASino::Listener.const_get(listener_name).new(self)
    @processor = CASinoCore::Processor.const_get(processor_name).new(listener)
  end
end
