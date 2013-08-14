# This migration comes from casino (originally 20121225153637)
class AddPgtUrlToProxyGrantingTickets < ActiveRecord::Migration
  def up
    add_column :proxy_granting_tickets, :pgt_url, :string, null: true
    CASinoCore::Model::ProxyGrantingTicket.delete_all
    change_column :proxy_granting_tickets, :pgt_url, :string, null: false
  end

  def down
    remove_column :proxy_granting_tickets, :pgt_url
  end
end
