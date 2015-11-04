require 'spec_helper'

describe CASino::ServiceRule do
  describe '.allowed?' do
    context 'with an empty table' do
      context 'with default settings' do
        ['https://www.example.org/', 'http://www.google.com/'].each do |service_url|
          it "allows access to #{service_url}" do
            described_class.allowed?(service_url).should == true
          end
        end
      end

      context 'with require_service_rules option' do
        before(:each) do
          CASino.config.require_service_rules = true
        end

        ['https://www.example.org/', 'http://www.google.com/'].each do |service_url|
          it "does not allow access to #{service_url}" do
            described_class.allowed?(service_url).should == false
          end
        end
      end
    end

    context 'with a regex rule' do
      before(:each) do
        FactoryGirl.create :service_rule, :regex, url: '^https://.*'
      end

      ['https://www.example.org/', 'https://www.google.com/'].each do |service_url|
        it "allows access to #{service_url}" do
          described_class.allowed?(service_url).should == true
        end
      end

      ['http://www.example.org/', 'http://www.google.com/'].each do |service_url|
        it "does not allow access to #{service_url}" do
          described_class.allowed?(service_url).should == false
        end
      end
    end

    context 'with many regex rules' do
      before(:each) do
        100.times do |counter|
          FactoryGirl.create :service_rule, :regex, url: "^https://www#{counter}.example.com"
        end
      end

      let(:service_url) { 'https://www111.example.com/bla' }

      it 'does not take too long to check a denied service' do
        start = Time.now
        described_class.allowed?(service_url).should == false
        (Time.now - start).should < 1.0
      end
    end

    context 'with a non-regex rule' do
      before(:each) do
        FactoryGirl.create :service_rule, url: 'https://www.google.com/foo'
      end

      ['https://www.google.com/foo'].each do |service_url|
        it "allows access to #{service_url}" do
          described_class.allowed?(service_url).should == true
        end
      end

      ['https://www.example.org/', 'http://www.example.org/', 'https://www.google.com/test'].each do |service_url|
        it "does not allow access to #{service_url}" do
          described_class.allowed?(service_url).should == false
        end
      end
    end
  end
end
