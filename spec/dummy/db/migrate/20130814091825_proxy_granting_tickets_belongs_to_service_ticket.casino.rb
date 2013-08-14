# This migration comes from casino (originally 20121223135227)
require 'casino_core/model'

class ProxyGrantingTicketsBelongsToServiceTicket < ActiveRecord::Migration
  def change
    CASinoCore::Model::ProxyGrantingTicket.delete_all

    remove_index :proxy_granting_tickets, :ticket_granting_ticket_id
    remove_column :proxy_granting_tickets, :ticket_granting_ticket_id

    add_column :proxy_granting_tickets, :service_ticket_id, :integer
    change_column :proxy_granting_tickets, :service_ticket_id, :integer, null: false
    add_index :proxy_granting_tickets, :service_ticket_id
  end
end
