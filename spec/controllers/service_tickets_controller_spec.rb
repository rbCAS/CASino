require 'spec_helper'

describe ServiceTicketsController do
  describe 'GET "validate"' do
    let(:ticket_granting_ticket) {
      TicketGrantingTicket.create! ticket: 'TGC-123', username: 'user1', user_agent: 'Foobar 5'
    }

    let(:service_ticket) {
      ticket_granting_ticket.service_tickets.create! ticket: 'ST-12345', service: 'https://example.com/cas-service'
    }

    context 'with an unconsumed service ticket' do
      before(:each) do
        get :validate, service: service_ticket.service, ticket: service_ticket.ticket
      end

      it 'should be successful' do
        response.should be_success
      end

      it 'should render the validate page' do
        response.should render_template('validate')
      end

      it 'should consume the service ticket' do
        service_ticket.reload
        service_ticket.consumed.should == true
      end

      it 'should find the right user' do
        assigns(:username).should == ticket_granting_ticket.username
      end
    end

    context 'with an consumed service ticket' do
      before(:each) do
        service_ticket.consumed = true
        service_ticket.save!
        get :validate, service: service_ticket.service, ticket: service_ticket.ticket
      end

      it 'should be successful' do
        response.should be_success
      end

      it 'should render the validate page' do
        response.should render_template('validate')
      end

      it 'should not find the user' do
        assigns(:username).should be_nil
      end
    end
  end
end
