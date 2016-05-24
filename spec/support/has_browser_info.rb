shared_examples 'has browser info' do
  describe '#browser_info' do
    let(:user_agent) { Object.new }
    before(:each) do
      user_agent.stub(:browser).and_return('TestBrowser')
      UserAgent.stub(:parse).and_return(user_agent)
    end

    context 'without platform' do
      before(:each) do
        user_agent.stub(:platform).and_return(nil)
      end

      it 'returns the browser name' do
        subject.browser_info.should == 'TestBrowser'
      end
    end

    context 'with a platform' do
      before(:each) do
        user_agent.stub(:platform).and_return('Linux')
      end

      it 'returns the browser name' do
        subject.browser_info.should == 'TestBrowser (Linux)'
      end
    end
  end
end
