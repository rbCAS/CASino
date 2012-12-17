require 'spec_helper'

describe CASino::Listener::LoginCredentialAcceptor do
  include Rails.application.routes.url_helpers
  let(:controller) { Object.new }
  let(:listener) { described_class.new(controller) }

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
        controller.should_receive(:redirect_to).with(sessions_path, status: :see_other)
        listener.user_logged_in(url)
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
end
