class AddAuthenticatorToTicketGrantingTickets < ActiveRecord::Migration
  def up
    add_column :ticket_granting_tickets, :authenticator, :string, null: true
    CASinoCore::Model::TicketGrantingTicket.delete_all
    change_column :ticket_granting_tickets, :authenticator, :string, null: false
    add_index :ticket_granting_tickets, [:authenticator, :username]
    remove_index :ticket_granting_tickets, :username
  end

  def down
    remove_index :ticket_granting_tickets, [:authenticator, :username]
    remove_column :ticket_granting_tickets, :authenticator
    add_index :ticket_granting_tickets, :username
  end
end
