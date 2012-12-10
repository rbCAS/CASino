require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

class CASinoCore::Processor::Logout < CASinoCore::Processor
  include CASinoCore::Helper

  def process(params = nil, cookies = nil)
    params = params || {}
    cookies ||= {}
    session_destroyer = CASinoCore::Processor::SessionDestroyer.new(DummyListener.new)
    session_destroyer.process(cookies[:tgt])
    @listener.user_logged_out(params[:url])
  end

  class DummyListener
    def ticket_deleted(*args)
    end

    def ticket_not_found(*args)
    end
  end
end
