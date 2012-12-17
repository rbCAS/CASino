require 'spec_helper'

describe CASino::Listener::SessionDestroyer do
  include Rails.application.routes.url_helpers
  let(:controller) { Struct.new(:cookies).new(cookies: {}) }
  let(:listener) { described_class.new(controller) }

  before(:each) do
    controller.stub(:redirect_to)
  end

  describe '#ticket_not_found' do
    it 'redirects back to the session overview' do
      controller.should_receive(:redirect_to).with(sessions_path)
      listener.ticket_not_found
    end
  end

  describe '#ticket_deleted' do
    it 'redirects back to the session overview' do
      controller.should_receive(:redirect_to).with(sessions_path)
      listener.ticket_deleted
    end
  end
end
