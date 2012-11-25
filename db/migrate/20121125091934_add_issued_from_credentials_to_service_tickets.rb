class AddIssuedFromCredentialsToServiceTickets < ActiveRecord::Migration
  def change
    add_column :service_tickets, :issued_from_credentials, :boolean, null: false, default: false
  end
end
