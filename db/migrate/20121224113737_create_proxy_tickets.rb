class CreateProxyTickets < ActiveRecord::Migration
  def change
    create_table :proxy_tickets do |t|
      t.string :ticket, null: false
      t.string :service, null: false
      t.boolean :consumed, null: false, default: false
      t.integer :proxy_granting_ticket_id, null: false

      t.timestamps
    end

    add_index :proxy_tickets, :ticket, unique: true
    add_index :proxy_tickets, :proxy_granting_ticket_id
  end
end
