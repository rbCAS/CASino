# This migration comes from casino (originally 20121226192211)
class FixIndexForGranterOnProxyGrantingTicket < ActiveRecord::Migration
  def change
    remove_index :proxy_granting_tickets, :service_ticket_id
    add_index :proxy_granting_tickets, [:granter_type, :granter_id], unique: true
  end
end
