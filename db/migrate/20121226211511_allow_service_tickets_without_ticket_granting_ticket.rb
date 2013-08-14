class AllowServiceTicketsWithoutTicketGrantingTicket < ActiveRecord::Migration
  def change
    change_column :service_tickets, :ticket_granting_ticket_id, :integer, null: true
  end
end
