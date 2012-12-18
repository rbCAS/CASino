require 'spec_helper'

describe CASino::Listener::LegacyValidator do
  let(:controller) { Object.new }
  let(:listener) { described_class.new(controller) }
  let(:text) { "foobar\nbla\n" }
  let(:render_parameters) { { text: text, content_type: 'text/plain' } }

  describe '#validation_succeeded' do
    it 'tells the controller to render the response text' do
      controller.should_receive(:render).with(render_parameters)
      listener.validation_succeeded(text)
    end
  end

  describe '#validation_failed' do
    it 'tells the controller to render the response text' do
      controller.should_receive(:render).with(render_parameters)
      listener.validation_failed(text)
    end
  end
end
