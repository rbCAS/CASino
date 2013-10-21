require 'spec_helper'

describe CASino::LoginCredentialRequestorListener do
  include CASino::Engine.routes.url_helpers
  let(:controller) { Struct.new(:cookies).new(cookies: {}) }
  let(:listener) { described_class.new(controller) }

  describe '#user_not_logged_in' do
    let(:login_ticket) { Object.new }
    it 'assigns the login ticket' do
      listener.user_not_logged_in(login_ticket)
      controller.instance_variable_get(:@login_ticket).should == login_ticket
    end

    it 'deletes an existing ticket-granting ticket cookie' do
      controller.cookies = { tgt: 'TGT-12345' }
      listener.user_not_logged_in(login_ticket)
      controller.cookies[:tgt].should be_nil
    end
  end

  describe '#user_logged_in' do
    context 'with a service url' do
      let(:url) { 'http://www.example.com/?ticket=ST-123' }
      it 'tells the controller to redirect the client' do
        controller.should_receive(:redirect_to).with(url, status: :see_other)
        listener.user_logged_in(url)
      end
    end

    context 'without a service url' do
      let(:url) { nil }
      it 'tells the controller to redirect to the session overview' do
        controller.should_receive(:redirect_to).with(sessions_path)
        listener.user_logged_in(url)
      end
    end
  end

  context '#service_not_allowed' do
    let(:service) { 'http://www.example.com/foo' }

    before(:each) do
      controller.stub(:render)
    end

    it 'tells the controller to render the service_not_allowed template' do
      controller.should_receive(:render).with('service_not_allowed', status: 403)
      listener.send(:service_not_allowed, service)
    end

    it 'assigns the not allowed service' do
      listener.send(:service_not_allowed, service)
      controller.instance_variable_get(:@service).should == service
    end
  end
end
