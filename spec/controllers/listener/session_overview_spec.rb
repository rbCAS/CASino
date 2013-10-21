require 'spec_helper'

describe CASino::SessionOverviewListener do
  include CASino::Engine.routes.url_helpers
  let(:controller) { Object.new }
  let(:listener) { described_class.new(controller) }

  describe '#user_not_logged_in' do
    before(:each) do
      controller.stub(:redirect_to)
    end

    it 'redirects to the login page' do
      controller.should_receive(:redirect_to).with(login_path)
      listener.user_not_logged_in
    end
  end

  describe '#ticket_granting_tickets_found' do
    let(:ticket_granting_tickets) { [ Object.new, Object.new ] }
    it 'assigns the ticket-granting tickets' do
      listener.ticket_granting_tickets_found(ticket_granting_tickets)
      controller.instance_variable_get(:@ticket_granting_tickets).should == ticket_granting_tickets
    end
  end
end
