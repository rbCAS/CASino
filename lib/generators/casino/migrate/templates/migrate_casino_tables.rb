class MigrateCASinoTables < ActiveRecord::Migration
  # Renames the old CASinoCore database tables to new names that reflect Rails'
  # default naming schema.
  #
  # Since indices are silently dropped when tables are renamed in Rails <4, we
  # must check to see if the database renamed the associated indices and
  # reconstruct them if not.
  #
  # For more information, see: https://github.com/rails/rails/pull/8645
  def change
    # Login Tickets
    rename_table :login_tickets, :casino_login_tickets
    unless index_exists?(:casino_login_tickets, :ticket)
      add_index :casino_login_tickets, :ticket, :unique => true
    end

    # Proxy Granting Tickets
    rename_table :proxy_granting_tickets, :casino_proxy_granting_tickets
    unless index_exists?(:casino_proxy_granting_tickets, :ticket)
      add_index :casino_proxy_granting_tickets, :ticket, :unique => true
    end
    unless index_exists?(:casino_proxy_granting_tickets, :iou)
      add_index :casino_proxy_granting_tickets, :iou, :unique => true
    end
    unless index_exists?(:casino_proxy_granting_tickets, :name => "index_casino_proxy_granting_tickets_on_granter")
      # Uses a custom index name because the generated one exceeds the size limit
      add_index :casino_proxy_granting_tickets, [:granter_type, :granter_id], :name => "index_casino_proxy_granting_tickets_on_granter", :unique => true
    end

    # Proxy Tickets
    rename_table :proxy_tickets, :casino_proxy_tickets
    unless index_exists?(:casino_proxy_tickets, :ticket)
      add_index :casino_proxy_tickets, :ticket, :unique => true
    end
    unless index_exists?(:casino_proxy_tickets, :proxy_granting_ticket_id)
      add_index :casino_proxy_tickets, :proxy_granting_ticket_id
    end

    # Service Rules
    rename_table :service_rules, :casino_service_rules
    unless index_exists?(:casino_service_rules, :url)
      add_index :casino_service_rules, :url, :unique => true
    end

    # Service Tickets
    rename_table :service_tickets, :casino_service_tickets
    unless index_exists?(:casino_service_tickets, :ticket)
      add_index :casino_service_tickets, :ticket, :unique => true
    end
    unless index_exists?(:casino_service_tickets, :ticket_granting_ticket_id)
      add_index :casino_service_tickets, :ticket_granting_ticket_id
    end

    # Ticket Granting Tickets
    rename_table :ticket_granting_tickets, :casino_ticket_granting_tickets
    unless index_exists?(:casino_ticket_granting_tickets, :ticket)
      add_index :casino_ticket_granting_tickets, :ticket, :unique => true
    end

    # Two-Factor Authenticators
    rename_table :two_factor_authenticators, :casino_two_factor_authenticators
    unless index_exists?(:casino_two_factor_authenticators, :user_id)
      add_index :casino_two_factor_authenticators, :user_id
    end

    # Users
    rename_table :users, :casino_users
    unless index_exists?(:casino_users, [:authenticator, :username])
      add_index :casino_users, [:authenticator, :username], :unique => true
    end
  end
end