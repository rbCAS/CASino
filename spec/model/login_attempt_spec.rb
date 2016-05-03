require 'spec_helper'

describe CASino::LoginAttempt do

  subject { described_class.new username: 'some@body.ch', user_agent: 'TestBrowser' }

  it_behaves_like 'has browser info'

  describe '#username=' do
    context 'with existing user' do
      let(:user) { FactoryGirl.create :user, username: 'some@body.ch' }

      before do
        user.touch
      end

      it 'sets user' do
        expect(subject.user).to eq user
      end
    end
  end
end
