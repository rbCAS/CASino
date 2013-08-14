# This migration comes from casino (originally 20121112154930)
class CreateTicketGrantingTickets < ActiveRecord::Migration
  def change
    create_table :ticket_granting_tickets do |t|
      t.string :ticket, null: false, unique: true
      t.string :username, null: false
      t.text :extra_attributes

      t.timestamps
    end
  end
end
