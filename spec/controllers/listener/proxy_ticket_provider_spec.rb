require 'spec_helper'

describe CASino::ProxyTicketProviderListener do
  let(:controller) { Object.new }
  let(:listener) { described_class.new(controller) }
  let(:xml) { "<foo><bar>bla</bar></foo>" }
  let(:render_parameters) { { xml: xml } }

  describe '#request_succeeded' do
    it 'tells the controller to render the response xml' do
      controller.should_receive(:render).with(render_parameters)
      listener.request_succeeded(xml)
    end
  end

  describe '#request_failed' do
    it 'tells the controller to render the response xml' do
      controller.should_receive(:render).with(render_parameters)
      listener.request_failed(xml)
    end
  end
end
