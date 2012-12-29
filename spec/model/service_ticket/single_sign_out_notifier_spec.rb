require 'spec_helper'
require 'nokogiri'

describe CASinoCore::Model::ServiceTicket::SingleSignOutNotifier do
  let(:ticket) { 'ST-123456' }
  let(:service) { 'http://www.example.org/' }
  let(:service_ticket) { CASinoCore::Model::ServiceTicket.create ticket: ticket, service: service }
  let(:notifier) { described_class.new service_ticket }

  describe '#notify' do
    before(:each) do
      stub_request(:post, service)
    end

    it 'sends a valid Single Sign Out XML to the service URL' do
      notifier.notify
      WebMock.should have_requested(:post, service).with { |request|
        post_params = CGI.parse(request.body)
        post_params.should_not be_nil
        xml = Nokogiri::XML post_params['logoutRequest'].first
        xml.at_xpath('/samlp:LogoutRequest/samlp:SessionIndex').text.strip.should == service_ticket.ticket
      }
    end

    context 'when it is a success' do
      it 'returns true' do
        notifier.notify.should == true
      end
    end

    context 'with server error' do
      [404, 500].each do |status_code|
        context "#{status_code}" do
          before(:each) do
            stub_request(:post, service).to_return status: status_code
          end

          it 'returns false' do
            notifier.notify.should == false
          end
        end
      end
    end
  end
end