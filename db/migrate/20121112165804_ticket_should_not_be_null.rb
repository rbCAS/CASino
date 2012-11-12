class TicketShouldNotBeNull < ActiveRecord::Migration
  def change
    change_column :login_tickets, :ticket, :string, null: false, unique: true
  end
end
