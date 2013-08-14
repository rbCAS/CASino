# This migration comes from casino (originally 20121125185415)
class CreateProxyGrantingTickets < ActiveRecord::Migration
  def change
    create_table :proxy_granting_tickets do |t|
      t.string :ticket, null: false
      t.string :iou, null: false
      t.integer :ticket_granting_ticket_id, null: false

      t.timestamps
    end
    add_index :proxy_granting_tickets, :ticket, unique: true
    add_index :proxy_granting_tickets, :iou, unique: true
    add_index :proxy_granting_tickets, :ticket_granting_ticket_id
  end
end
