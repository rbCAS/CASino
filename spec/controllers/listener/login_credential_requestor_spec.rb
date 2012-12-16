require 'spec_helper'

describe CASino::Listener::LoginCredentialRequestor do
  include Rails.application.routes.url_helpers
  let(:controller) { Object.new }
  let(:listener) { described_class.new(controller) }

  describe '#user_not_logged_in' do
    let(:login_ticket) { Object.new }
    it 'assigns the login ticket' do
      listener.user_not_logged_in(login_ticket)
      controller.instance_variable_get(:@login_ticket).should == login_ticket
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
end
