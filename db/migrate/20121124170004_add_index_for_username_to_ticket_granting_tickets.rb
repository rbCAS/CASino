class AddIndexForUsernameToTicketGrantingTicket < ActiveRecord::Migration
  def change
    add_index :ticket_granting_tickets, :username
  end
end
