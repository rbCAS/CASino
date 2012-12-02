require 'spec_helper'

describe CASinoCore::Processor::LoginCredentialRequestor do
  describe '#process' do
    context 'when logged out' do
      it 'should call the render_login_page method on the listener' do
        object = Object.new
        object.should_receive(:render_login_page).with(kind_of(CASinoCore::Model::LoginTicket))
        processor = described_class.new(object)
        processor.process
      end
    end
  end
end
