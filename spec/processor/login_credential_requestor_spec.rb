require 'spec_helper'

describe CASinoCore::Processor::LoginCredentialRequestor do
  describe '#process' do
    let(:listener) { Object.new }
    let(:processor) { described_class.new(listener) }

    context 'when logged out' do
      it 'should call the #user_not_logged_in method on the listener' do
        listener.should_receive(:user_not_logged_in).with(kind_of(CASinoCore::Model::LoginTicket))
        processor.process
      end
    end

    context 'when logged in' do
      context 'with a service' do
        it 'should call the #user_logged_in method on the listener' do
          listener.should_receive(:user_logged_in).with('http://example.com/?ticket=foo')
          processor.process({ service: 'http://example.com/' }, { tgt: 'bla' })
        end
      end

      context 'without a service' do
        it 'should call the #user_logged_in method on the listener' do
          listener.should_receive(:user_logged_in).with(nil)
          processor.process(nil, { tgt: 'bla' })
        end
      end
    end
  end
end
