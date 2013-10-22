require 'spec_helper'

describe CASino::ProcessorConcern::ServiceTickets do
  let(:class_with_mixin) {
    Class.new do
      include CASino::ProcessorConcern::ServiceTickets
    end
  }
  subject {
    class_with_mixin.new
  }

  describe '#acquire_service_ticket' do
    let(:ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }
    let(:service) { 'http://www.example.com/' }

    context 'with a ticket-granting ticket with existing service tickets' do
      let!(:service_ticket) { FactoryGirl.create :service_ticket, ticket_granting_ticket: ticket_granting_ticket, service: service }
      let!(:other_service_ticket) { FactoryGirl.create :service_ticket, ticket_granting_ticket: ticket_granting_ticket }

      it 'does not change the service tickets count' do
        expect do
          subject.acquire_service_ticket(ticket_granting_ticket, service)
        end.to_not change(CASino::ServiceTicket, :count)
      end

      it 'deletes the old service ticket' do
        subject.acquire_service_ticket(ticket_granting_ticket, service)
        expect { service_ticket.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a service url another ticket-granting ticket has a service ticket for' do
      let!(:service_ticket) { FactoryGirl.create :service_ticket, ticket_granting_ticket: ticket_granting_ticket, service: service }
      let!(:other_ticket_granting_ticket) { FactoryGirl.create :ticket_granting_ticket }

      it 'does change the service tickets count' do
        expect do
          subject.acquire_service_ticket(other_ticket_granting_ticket, service)
        end.to change(CASino::ServiceTicket, :count).by(1)
      end

      it 'does not delete the other service ticket' do
        subject.acquire_service_ticket(other_ticket_granting_ticket, service)
        expect { service_ticket.reload }.not_to raise_error
      end
    end
  end
end