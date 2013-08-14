# This migration comes from casino (originally 20121124170004)
class AddIndexForUsernameToTicketGrantingTickets < ActiveRecord::Migration
  def change
    add_index :ticket_granting_tickets, :username
  end
end
