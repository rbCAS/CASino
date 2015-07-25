require 'spec_helper'
require 'nokogiri'

describe CASino::ServiceTicket::SingleSignOutNotifier do
  let(:service_ticket) { FactoryGirl.create :service_ticket }
  let(:service) { service_ticket.service }
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
        xml.at_xpath('/samlp:LogoutRequest/samlp:SessionIndex').text.should == service_ticket.ticket
      }
    end

    it 'sets the timeout values' do
      [:read_timeout=, :open_timeout=].each do |timeout|
        Net::HTTP.any_instance.should_receive(timeout).with(CASino.config.service_ticket[:single_sign_out_notification][:timeout])
      end
      notifier.notify
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

      context 'connection timeout' do
        before(:each) do
          stub_request(:post, service).to_raise Timeout::Error
        end

        it 'returns false' do
          notifier.notify.should == false
        end
      end

      context 'network timeout' do
        before(:each) do
          stub_request(:post, service).to_raise Errno::ETIMEDOUT
        end

        it 'returns false' do
          notifier.notify.should == false
        end
      end
    end
  end
end
