require 'spec_helper'

describe CASinoCore::Processor::LoginCredentialAcceptor do
  describe '#process' do
    context 'without a valid login ticket' do
      it 'should call the #invalid_login_ticket method on the listener' do
        object = Object.new
        object.should_receive(:invalid_login_ticket).with()
        processor = described_class.new(object)
        processor.process
      end
    end
  end
end
