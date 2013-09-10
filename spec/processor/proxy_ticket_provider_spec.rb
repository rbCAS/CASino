require 'spec_helper'

describe CASino::ProxyTicketProviderProcessor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }
    let(:params) { { targetService: 'this_does_not_have_to_be_a_url' } }

    before(:each) do
      listener.stub(:request_failed)
      listener.stub(:request_succeeded)
    end

    context 'without proxy-granting ticket' do
      it 'calls the #request_failed method on the listener' do
        listener.should_receive(:request_failed)
        processor.process(params)
      end

      it 'does not create a proxy ticket' do
        lambda do
          processor.process(params)
        end.should_not change(CASino::ProxyTicket, :count)
      end
    end

    context 'with a not-existing proxy-granting ticket' do
      let(:params_with_deleted_pgt) { params.merge(pgt: 'PGT-123453789') }

      it 'calls the #request_failed method on the listener' do
        listener.should_receive(:request_failed)
        processor.process(params_with_deleted_pgt)
      end

      it 'does not create a proxy ticket' do
        lambda do
          processor.process(params_with_deleted_pgt)
        end.should_not change(CASino::ProxyTicket, :count)
      end
    end

    context 'with a proxy-granting ticket' do
      let(:proxy_granting_ticket) { FactoryGirl.create :proxy_granting_ticket }
      let(:params_with_valid_pgt) { params.merge(pgt: proxy_granting_ticket.ticket) }

      it 'calls the #request_succeeded method on the listener' do
        listener.should_receive(:request_succeeded)
        processor.process(params_with_valid_pgt)
      end

      it 'does not create a proxy ticket' do
        lambda do
          processor.process(params_with_valid_pgt)
        end.should change(proxy_granting_ticket.proxy_tickets, :count).by(1)
      end

      it 'includes the proxy ticket in the response' do
        listener.should_receive(:request_succeeded) do |response|
          proxy_ticket = CASino::ProxyTicket.last
          response.should =~ /<cas:proxyTicket>#{proxy_ticket.ticket}<\/cas:proxyTicket>/
        end
        processor.process(params_with_valid_pgt)
      end
    end
  end
end
