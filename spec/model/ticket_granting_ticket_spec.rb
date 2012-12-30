require 'spec_helper'

describe CASinoCore::Model::TicketGrantingTicket do
  let(:subject) { described_class.create! ticket: 'TGT-3ep9awhy2ty5UhL8wM1xAZ', username: 'example-user', authenticator: 'test' }
  let(:service_ticket) {
    subject.service_tickets.create! ticket: 'ST-12345', service: 'https://example.com/cas-service'
  }
  let(:consumed_service_ticket) {
    service_ticket = subject.service_tickets.create! ticket: 'ST-n9oZvDtYkVFHj5M3s59Ws5', service: 'https://example.com/cas-service'
    service_ticket.consumed = true
    service_ticket.save!
    service_ticket
  }

  describe '#destroy' do
    context 'when notification for a service ticket fails' do
      before(:each) do
        CASinoCore::Model::ServiceTicket::SingleSignOutNotifier.any_instance.stub(:notify).and_return(false)
      end

      it 'deletes depending proxy-granting tickets' do
        consumed_service_ticket.proxy_granting_tickets.create! ticket: 'PGT-12345', iou: 'PGTIOU-12345', pgt_url: 'bla'
        lambda {
          subject.destroy
        }.should change(CASinoCore::Model::ProxyGrantingTicket, :count).by(-1)
      end

      it 'nullifies depending service tickets' do
        lambda {
          subject.destroy
        }.should change { consumed_service_ticket.reload.ticket_granting_ticket_id }.from(subject.id).to(nil)
      end
    end
  end
end
