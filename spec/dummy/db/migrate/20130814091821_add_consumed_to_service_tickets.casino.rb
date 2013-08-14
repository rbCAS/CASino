# This migration comes from casino (originally 20121124195013)
class AddConsumedToServiceTickets < ActiveRecord::Migration
  def change
    add_column :service_tickets, :consumed, :boolean, null: false, default: false
  end
end
