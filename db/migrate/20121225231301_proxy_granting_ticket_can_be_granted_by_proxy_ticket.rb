class ProxyGrantingTicketCanBeGrantedByProxyTicket < ActiveRecord::Migration
  def up
    add_column :proxy_granting_tickets, :granter_type, :string, null: false, default: 'ServiceTicket'
    rename_column :proxy_granting_tickets, :service_ticket_id, :granter_id
  end
end
