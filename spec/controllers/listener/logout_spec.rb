require 'spec_helper'

describe CASino::Listener::Logout do
  include Rails.application.routes.url_helpers
  let(:controller) { Struct.new(:cookies).new(cookies: {}) }
  let(:listener) { described_class.new(controller) }

  describe '#user_logged_out' do
    let(:url) { 'http://www.example.com/test' }
    it 'assigns the url' do
      listener.user_logged_out(url)
      controller.instance_variable_get(:@url).should == url
    end

    it 'deletes an existing ticket-granting ticket cookie' do
      controller.cookies = { tgt: 'TGT-12345' }
      listener.user_logged_out(url)
      controller.cookies[:tgt].should be_nil
    end
  end
end
