require 'spec_helper'

describe CASinoCore::Model::TicketGrantingTicket do
  let(:ticket_granting_ticket) { described_class.create! ticket: 'TGT-3ep9awhy2ty5UhL8wM1xAZ', username: 'example-user', authenticator: 'test' }
  let(:service_ticket) { FactoryGirl.create :service_ticket, ticket_granting_ticket: ticket_granting_ticket }
  let(:consumed_service_ticket) { FactoryGirl.create :service_ticket, :consumed, ticket_granting_ticket: ticket_granting_ticket }

  describe '#destroy' do
    context 'when notification for a service ticket fails' do
      before(:each) do
        CASinoCore::Model::ServiceTicket::SingleSignOutNotifier.any_instance.stub(:notify).and_return(false)
      end

      it 'deletes depending proxy-granting tickets' do
        consumed_service_ticket.proxy_granting_tickets.create! ticket: 'PGT-12345', iou: 'PGTIOU-12345', pgt_url: 'bla'
        lambda {
          ticket_granting_ticket.destroy
        }.should change(CASinoCore::Model::ProxyGrantingTicket, :count).by(-1)
      end

      it 'nullifies depending service tickets' do
        lambda {
          ticket_granting_ticket.destroy
        }.should change { consumed_service_ticket.reload.ticket_granting_ticket_id }.from(ticket_granting_ticket.id).to(nil)
      end
    end
  end
end
