require 'spec_helper'

describe CASino::TicketValidatorListener do
  let(:controller) { Object.new }
  let(:listener) { described_class.new(controller) }
  let(:xml) { "<foo><bar>bla</bar></foo>" }
  let(:render_parameters) { { xml: xml } }

  describe '#validation_succeeded' do
    it 'tells the controller to render the response xml' do
      controller.should_receive(:render).with(render_parameters)
      listener.validation_succeeded(xml)
    end
  end

  describe '#validation_failed' do
    it 'tells the controller to render the response xml' do
      controller.should_receive(:render).with(render_parameters)
      listener.validation_failed(xml)
    end
  end
end
