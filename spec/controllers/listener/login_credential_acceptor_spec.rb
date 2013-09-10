require 'spec_helper'

describe CASino::LoginCredentialAcceptorListener do
  include CASino::Engine.routes.url_helpers
  let(:controller) { Struct.new(:cookies).new(cookies: {}) }
  let(:listener) { described_class.new(controller) }

  before(:each) do
    controller.stub(:redirect_to)
  end

  describe '#user_logged_in' do
    let(:ticket_granting_ticket) { 'TGT-123' }
    context 'with a service url' do
      let(:url) { 'http://www.example.com/?ticket=ST-123' }
      it 'tells the controller to redirect the client' do
        controller.should_receive(:redirect_to).with(url, status: :see_other)
        listener.user_logged_in(url, ticket_granting_ticket)
      end
    end

    context 'without a service url' do
      let(:url) { nil }
      it 'tells the controller to redirect to the session overview' do
        controller.should_receive(:redirect_to).with(sessions_path, status: :see_other)
        listener.user_logged_in(url, ticket_granting_ticket)
      end

      it 'creates the tgt cookie' do
        listener.user_logged_in(url, ticket_granting_ticket)
        controller.cookies[:tgt][:value].should == ticket_granting_ticket
      end
    end

    context 'with cookie expiry time' do
      let(:url) { Object.new }
      let(:expiry_time) { Time.now }
      it 'set the tgt cookie expiry time' do
        listener.user_logged_in(url, ticket_granting_ticket, expiry_time)
        controller.cookies[:tgt][:value].should == ticket_granting_ticket
        controller.cookies[:tgt][:expires].should == expiry_time
      end
    end
  end

  [:invalid_login_credentials, :invalid_login_ticket].each do |method|
    context "##{method}" do
      let(:login_ticket) { Object.new }
      let(:flash) { ActionDispatch::Flash::FlashHash.new }

      before(:each) do
        controller.stub(:render)
        controller.stub(:flash).and_return(flash)
      end

      it 'tells the controller to render the new template' do
        controller.should_receive(:render).with('new', status: 403)
        listener.send(method, login_ticket)
      end

      it 'assigns a new login ticket' do
        listener.send(method, login_ticket)
        controller.instance_variable_get(:@login_ticket).should == login_ticket
      end

      it 'should add an error message' do
        listener.send(method, login_ticket)
        flash[:error].should == I18n.t("login_credential_acceptor.#{method}")
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

  context '#two_factor_authentication_pending' do
    let(:ticket_granting_ticket) { 'TGT-123' }

    before(:each) do
      controller.stub(:render)
    end

    it 'tells the controller to render the service_not_allowed template' do
      controller.should_receive(:render).with('validate_otp')
      listener.send(:two_factor_authentication_pending, ticket_granting_ticket)
    end

    it 'assigns the not allowed service' do
      listener.send(:two_factor_authentication_pending, ticket_granting_ticket)
      controller.instance_variable_get(:@ticket_granting_ticket).should == ticket_granting_ticket
    end
  end
end
