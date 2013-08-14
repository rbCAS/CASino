# This migration comes from casino (originally 20121125190013)
class TicketsShouldBeUnique < ActiveRecord::Migration
  def change
    [:login_tickets, :service_tickets, :ticket_granting_tickets].each do |table|
      remove_index table, :ticket
      add_index table, :ticket, unique: true
    end
  end
end
