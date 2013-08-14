# This migration comes from casino (originally 20121124183542)
class CreateServiceTickets < ActiveRecord::Migration
  def change
    create_table :service_tickets do |t|
      t.string :ticket, null: false, unique: true
      t.string :service, null: false
      t.integer :ticket_granting_ticket_id, null: false

      t.timestamps
    end
    add_index :service_tickets, :ticket
    add_index :service_tickets, :ticket_granting_ticket_id
  end
end
