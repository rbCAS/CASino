# This migration comes from casino (originally 20140827183611)
class FixLengthOfTextFields < ActiveRecord::Migration
  def change
    change_column :casino_proxy_tickets, :service, :text, :limit => nil
    change_column :casino_service_tickets, :service, :text, :limit => nil
    change_column :casino_ticket_granting_tickets, :user_agent, :text, :limit => nil
  end
end
