# This migration comes from casino (originally 20140821142611)
class ChangeUserAgentToText < ActiveRecord::Migration
  def change
    change_column :casino_ticket_granting_tickets, :user_agent, :text
  end
end
