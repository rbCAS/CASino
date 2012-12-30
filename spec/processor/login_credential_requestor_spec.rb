require 'spec_helper'

describe CASinoCore::Processor::LoginCredentialRequestor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    context 'when logged out' do
      it 'calls the #user_not_logged_in method on the listener' do
        listener.should_receive(:user_not_logged_in).with(kind_of(CASinoCore::Model::LoginTicket))
        processor.process
      end
    end

    context 'when logged in' do
      let(:user_agent) { 'TestBrowser 1.0' }
      let(:ticket_granting_ticket) {
        CASinoCore::Model::TicketGrantingTicket.create!({
          ticket: 'TGC-9H6Vx4850i2Ksp3R8hTCwO',
          authenticator: 'test',
          username: 'test',
          extra_attributes: nil,
          user_agent: user_agent
        })
      }
      let(:cookies) { { tgt: ticket_granting_ticket.ticket } }

      before(:each) do
        listener.stub(:user_logged_in)
      end

      context 'with a service' do
        let(:service) { 'http://example.com/' }
        let(:params) { { service: service } }

        it 'calls the #user_logged_in method on the listener' do
          listener.should_receive(:user_logged_in).with(/^#{service}\?ticket=ST\-/)
          processor.process(params, cookies, user_agent)
        end

        it 'generates a service ticket' do
          lambda do
            processor.process(params, cookies, user_agent)
          end.should change(CASinoCore::Model::ServiceTicket, :count).by(1)
        end

        context 'with renew parameter' do
          it 'calls the #user_not_logged_in method on the listener' do
            listener.should_receive(:user_not_logged_in).with(kind_of(CASinoCore::Model::LoginTicket))
            processor.process(params.merge({ renew: 'true' }), cookies)
          end
        end
      end

      context 'without a service' do
        it 'calls the #user_logged_in method on the listener' do
          listener.should_receive(:user_logged_in).with(nil)
          processor.process(nil, cookies, user_agent)
        end

        it 'does not generate a service ticket' do
          lambda do
            processor.process(nil, cookies, user_agent)
          end.should change(CASinoCore::Model::ServiceTicket, :count).by(0)
        end

        context 'with a changed browser' do
          it 'calls the #user_not_logged_in method on the listener' do
            listener.should_receive(:user_not_logged_in).with(kind_of(CASinoCore::Model::LoginTicket))
            processor.process(nil, cookies)
          end
        end
      end
    end
  end
end
