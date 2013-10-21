require 'spec_helper'

describe CASino::SecondFactorAuthenticationAcceptorListener do
  include CASino::Engine.routes.url_helpers
  let(:controller) { Struct.new(:cookies).new(cookies: {}) }
  let(:listener) { described_class.new(controller) }

  before(:each) do
    controller.stub(:redirect_to)
  end

  describe '#user_not_logged_in' do
    it 'redirects to the login page' do
      controller.should_receive(:redirect_to).with(login_path)
      listener.user_not_logged_in
    end
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
        controller.cookies[:tgt].should == { value: ticket_granting_ticket, expires: nil }
      end
    end
  end

  context "#invalid_one_time_password" do
    let(:flash) { ActionDispatch::Flash::FlashHash.new }

    before(:each) do
      controller.stub(:render)
      controller.stub(:flash).and_return(flash)
    end

    it 'should add an error message' do
      listener.invalid_one_time_password
      flash[:error].should == I18n.t('validate_otp.invalid_otp')
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
