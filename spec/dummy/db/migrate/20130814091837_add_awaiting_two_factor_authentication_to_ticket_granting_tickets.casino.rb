# This migration comes from casino (originally 20130203155008)
class AddAwaitingTwoFactorAuthenticationToTicketGrantingTickets < ActiveRecord::Migration
  def change
    add_column :ticket_granting_tickets, :awaiting_two_factor_authentication, :boolean, null: false, default: false
  end
end
