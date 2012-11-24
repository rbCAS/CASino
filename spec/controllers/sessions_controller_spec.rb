require 'spec_helper'

describe SessionsController do
  describe 'GET "new"' do
    context 'when logged out' do
      before(:each) do
        get :new
      end

      it 'should be successful' do
        response.should be_success
      end

      it 'should render the new page' do
        response.should render_template('new')
      end
    end

    context 'when logged in' do
      before(:each) do
        @ticket = test_sign_in
      end

      context 'without a service set' do
        before(:each) do
          get :new
        end

        it 'should redirect to the index page' do
          response.should redirect_to(sessions_path)
        end
      end

      context 'with a service set' do
        before(:each) do
          @service = 'https://example.com/lala'
          get :new, {
            service: @service
          }
          @service_ticket = ServiceTicket.last
        end

        it 'should redirect to the service' do
          response.should redirect_to("https://example.com/lala?ticket=#{@service_ticket.ticket}")
        end
      end
    end
  end

  describe 'GET "index"' do
    context 'when logged out' do
      before(:each) do
        get :index
      end

      it 'should render the new page' do
        response.should render_template('new')
      end

      it 'should have a flash message' do
        flash[:error].should =~ /please sign in/i
      end

      it 'should respond with a 403' do
        response.response_code.should == 403
      end
    end

    context 'when logged in' do
      before(:each) do
        test_sign_in
        get :index
      end

      it 'should be successful' do
        response.should be_success
      end

      it 'should render the index page' do
        response.should render_template('index')
      end

      it 'should list all open sessions' do
        assigns(:ticket_granting_tickets).count.should >= 1
      end
    end
  end

  describe 'POST "create"' do
    context 'without a valid login ticket' do
      before(:each) do
        post :create
      end

      it 'should render the new page' do
        response.should render_template('new')
      end

      it 'should have a flash message' do
        flash[:error].should =~ /no valid login ticket/i
      end

      it 'should respond with a 403' do
        response.response_code.should == 403
      end
    end

    context 'with a valid login ticket' do
      context 'with invalid login data' do
        before(:each) do
          ticket = LoginTicket.create! ticket: 'LT-54321'
          post :create, {
            lt: ticket.ticket,
            username: 'bla',
            password: 'test123'
          }
        end

        it { should_not be_signed_in }

        it 'should render the new page' do
          response.should render_template('new')
        end

        it 'should have a flash message' do
          flash[:error].should =~ /incorrect/i
        end

        it 'should respond with a 403' do
          response.response_code.should == 403
        end
      end

      context 'with valid login data' do
        before(:each) do
          ticket = LoginTicket.create! ticket: 'LT-43821'
          post :create, {
            lt: ticket.ticket,
            username: 'testuser',
            password: 'foobar123'
          }
        end

        it { should be_signed_in }

        it 'should redirect to the index page' do
          response.should redirect_to(sessions_path)
        end
      end
    end
  end

  describe 'DELETE "destroy"' do
    context 'when logged in' do
      context 'with current sessions\' ticket' do
        before(:each) do
          @ticket = test_sign_in
          delete :destroy, {
            id: @ticket.id
          }
        end

        it 'should redirect to the index page' do
          response.should redirect_to(sessions_path)
        end

        it 'should not delete the current ticket-granting ticket' do
          TicketGrantingTicket.find(@ticket.id)
        end
      end

      context 'with an other ticket' do
        before(:each) do
          @other_ticket = test_sign_in
          @ticket = test_sign_in
          delete :destroy, {
            id: @other_ticket.id
          }
        end

        it 'should redirect to the index page' do
          response.should redirect_to(sessions_path)
        end

        it 'should not delete the current ticket-granting ticket' do
          TicketGrantingTicket.find(@ticket.id)
        end

        it 'should delete the other ticket' do
          TicketGrantingTicket.where(id: @other_ticket.id).first.should be_nil
        end
      end
    end
  end

  describe 'GET "logout"' do
    context 'when logged in' do
      before(:each) do
        @other_ticket = test_sign_in
        @ticket = test_sign_in
        get :logout
      end

      it 'should redirect to the login page' do
        response.should redirect_to(login_path)
      end

      it 'should delete the sessions\' ticket-granting ticket' do
        TicketGrantingTicket.where(id: @ticket.id).first.should be_nil
      end

      it 'should not delete other ticket-granting tickets' do
        TicketGrantingTicket.find(@other_ticket.id)
      end

      it 'should delete the tgt cookie' do
        cookies[:tgt].should be_nil
      end
    end
  end
end
