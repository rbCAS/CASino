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
      let(:ticket) {
        CASinoCore::Model::TicketGrantingTicket.create!({
          ticket: 'TGC-9H6Vx4850i2Ksp3R8hTCwO',
          username: 'test',
          extra_attributes: nil,
          user_agent: user_agent
        })
      }
      context 'with the right browser' do
        context 'with a service' do
          it 'calls the #user_logged_in method on the listener' do
            listener.should_receive(:user_logged_in).with('http://example.com/?ticket=foo')
            processor.process({ service: 'http://example.com/' }, { tgt: ticket.ticket }, user_agent)
          end
        end

        context 'without a service' do
          it 'calls the #user_logged_in method on the listener' do
            listener.should_receive(:user_logged_in).with(nil)
            processor.process(nil, { tgt: ticket.ticket }, user_agent)
          end
        end
      end

      context 'with a changed browser' do
        it 'calls the #user_not_logged_in method on the listener' do
          listener.should_receive(:user_not_logged_in).with(kind_of(CASinoCore::Model::LoginTicket))
          processor.process(nil, { tgt: ticket.ticket })
        end
      end
    end
  end
end
