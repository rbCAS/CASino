require 'spec_helper'

describe Cas::V1::TicketsController do

  describe "POST /cas/v1/tickets" do
    context "with correct credentials" do
      it 'returns a 201 Created' do
        CASinoCore::Processor::LoginCredentialAcceptor.any_instance.should_receive(:process) do
          @controller.user_logged_in
        end

        post :create, params: {username: 'valid', password: 'invalid'}

        response.response_code.should eq(201)
      end
    end
  end

  describe "POST /cas/v1/tickets/{TGT id}" do
  end

  describe "DELETE /cas/v1/tickets/TGT-fdsjfsdfjkalfewrihfdhfaie" do
  end

end
