require 'grape'

class CASino::API < Grape::API
  format :json

  mount CASino::API::Resource::AuthTokenTickets
end
