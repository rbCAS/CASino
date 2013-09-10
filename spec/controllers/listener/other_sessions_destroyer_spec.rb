require 'spec_helper'

describe CASino::OtherSessionsDestroyerListener do
  include CASino::Engine.routes.url_helpers
  let(:controller) { Struct.new(:cookies).new(cookies: {}) }
  let(:listener) { described_class.new(controller) }

  before(:each) do
    controller.stub(:redirect_to)
  end

  describe '#other_sessions_destroyed' do
    let(:service) { 'http://www.example.com/' }
    it 'redirects back to the URL' do
      controller.should_receive(:redirect_to).with(service)
      listener.other_sessions_destroyed(service)
    end
  end
end
