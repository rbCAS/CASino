class AddConsumedToServiceTickets < ActiveRecord::Migration
  def change
    add_column :service_tickets, :consumed, :boolean, null: false, default: false
  end
end
