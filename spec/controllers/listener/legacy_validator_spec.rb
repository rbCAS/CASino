require 'spec_helper'

describe CASino::LegacyValidatorListener do
  let(:controller) { Object.new }
  let(:listener) { described_class.new(controller) }
  let(:response_text) { "foobar\nbla\n" }
  let(:render_parameters) { { text: response_text, content_type: 'text/plain' } }

  describe '#validation_succeeded' do
    it 'tells the controller to render the response text' do
      controller.should_receive(:render).with(render_parameters)
      listener.validation_succeeded(response_text)
    end
  end

  describe '#validation_failed' do
    it 'tells the controller to render the response text' do
      controller.should_receive(:render).with(render_parameters)
      listener.validation_failed(response_text)
    end
  end
end
