# This migration comes from casino (originally 20121112165804)
class TicketShouldNotBeNull < ActiveRecord::Migration
  def change
    change_column :login_tickets, :ticket, :string, null: false, unique: true
  end
end
