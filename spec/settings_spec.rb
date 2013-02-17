require 'spec_helper'

describe CASinoCore::Settings do
  describe 'initializer' do
    it 'loads default settings' do
      described_class.service_ticket[:lifetime_consumed].should == 86400
    end
    it 'overwrites specific settings' do
      described_class.service_ticket[:lifetime_unconsumed].should == 299
    end
  end

  describe '.add_defaults' do
    it 'allows to set a overwritable default' do
      CASinoCore::Settings.add_defaults :frontend, { foo: 'bar', example: 'test' }
      CASinoCore::Settings.init frontend: { foo: 'test', test: 'example' }
      CASinoCore::Settings.frontend.should == { foo: 'test', example: 'test', test: 'example' }
    end
  end

  describe '#authenticators=' do
    context 'with an authenticator name' do
      let(:authenticator_name) { 'testing' }
      let(:gem_name) { "casino_core-authenticator-#{authenticator_name}" }
      let(:options) { { } }
      let(:authenticators) {
        {
          test_1: {
            authenticator: authenticator_name,
            options: options
          }
        }
      }

      context 'when the authenticator exists' do
        let(:class_name) { 'Testing' }
        let(:authenticator) { CASinoCore::Authenticator::Static }

        before(:each) do
          CASinoCore::Settings.stub(:require)
          CASinoCore::Authenticator.stub(:const_get).and_return(authenticator)
        end

        it 'loads the required file' do
          CASinoCore::Settings.should_receive(:require).with(gem_name)
          described_class.authenticators = authenticators
        end

        it 'instantiates the authenticator' do
          CASinoCore::Authenticator.should_receive(:const_get).with(class_name).and_return(authenticator)
          described_class.authenticators = authenticators
        end
      end

      context 'when the authenticator does not exist' do
        before(:each) do
          CASinoCore::Settings.stub(:require) do
            raise LoadError, 'cannot load such file'
          end
        end

        it 'raises an error' do
          lambda {
            described_class.authenticators = authenticators
          }.should raise_error(LoadError)
        end
      end
    end
  end
end
