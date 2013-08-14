# This migration comes from casino (originally 20121124183732)
class AddTicketIndexes < ActiveRecord::Migration
  def change
    add_index :ticket_granting_tickets, :ticket
    add_index :login_tickets, :ticket
  end
end
