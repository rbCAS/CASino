# This migration comes from casino (originally 20121122180310)
class AddUserAgentToTicketGrantingTickets < ActiveRecord::Migration
  def change
    add_column :ticket_granting_tickets, :user_agent, :string
  end
end
