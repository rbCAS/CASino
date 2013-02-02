class CreateUsers < ActiveRecord::Migration
  def up
    tgt = CASinoCore::Model::TicketGrantingTicket.new
    tgt.authenticator = 'foo'
    tgt.username = 'bar'
    tgt.ticket = 'TGT-bla'
    tgt.save!

    create_table :users do |t|
      t.string :authenticator, null: false
      t.string :username, null: false
      t.text :extra_attributes

      t.timestamps
    end

    add_index :users, [:authenticator, :username], unique: true

    remove_index :ticket_granting_tickets, [:authenticator, :username]
    add_column :ticket_granting_tickets, :user_id, :integer, null: true
    CASinoCore::Model::TicketGrantingTicket.reset_column_information
    CASinoCore::Model::TicketGrantingTicket.all.each do |ticket|
      user = CASinoCore::Model::User.where(
        authenticator: ticket.authenticator,
        username: ticket.username).first_or_initialize
      user.extra_attributes = ticket.extra_attributes
      user.save!
      ticket.user_id = user.id
      ticket.save!
    end
    change_column :ticket_granting_tickets, :user_id, :integer, null: false
    remove_columns :ticket_granting_tickets, :authenticator, :username, :extra_attributes
  end
end
