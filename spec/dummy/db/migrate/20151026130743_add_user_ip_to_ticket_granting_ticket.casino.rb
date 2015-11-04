# This migration comes from casino (originally 20151022192752)
class AddUserIpToTicketGrantingTicket < ActiveRecord::Migration
  def up
    add_column :casino_ticket_granting_tickets, :user_ip, :string
  end

  def down
    remove_column :casino_ticket_granting_tickets, :user_ip
  end
end
