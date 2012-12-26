require 'spec_helper'

describe CASinoCore::Authenticator do
  subject {
    CASinoCore::Authenticator.new
  }

  context '#validate' do
    it 'should raise an error' do
      expect { subject.validate(nil, nil) }.to raise_error(NotImplementedError)
    end
  end
end
