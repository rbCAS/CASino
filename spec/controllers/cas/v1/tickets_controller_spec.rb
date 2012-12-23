require 'spec_helper'

describe Cas::V1::TicketsController do

  describe "POST /cas/v1/tickets" do
    context "with correct credentials" do
      it 'returns a 201 Created' do
        CASinoCore::Processor::LoginCredentialAcceptor.any_instance.should_receive(:process) do
          @listener.user_logged_in
        end

        post :create, params: {username: 'valid', password: 'invalid'}
      end
      #processor(:LoginCredentialAcceptor).process(params, cookies, request.user_agent)
    end
  end

  describe "POST /cas/v1/tickets/{TGT id}" do
  end

  describe "DELETE /cas/v1/tickets/TGT-fdsjfsdfjkalfewrihfdhfaie" do
  end

end
