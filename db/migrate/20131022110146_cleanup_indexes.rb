class CleanupIndexes < ActiveRecord::Migration
  def change
    # delete some leftovers in migrated CASino 1.x installations
    remove_deprecated_index_if_exists :login_tickets, [:ticket]
    remove_deprecated_index_if_exists :proxy_granting_tickets, [:granter_type, :granter_id]
    remove_deprecated_index_if_exists :proxy_granting_tickets, [:iou]
    remove_deprecated_index_if_exists :proxy_tickets, [:proxy_granting_ticket_id]
    remove_deprecated_index_if_exists :proxy_tickets, [:ticket]
    remove_deprecated_index_if_exists :service_rules, [:url]
    remove_deprecated_index_if_exists :service_tickets, [:ticket]
    remove_deprecated_index_if_exists :service_tickets, [:ticket_granting_ticket_id]
    remove_deprecated_index_if_exists :ticket_granting_tickets, [:ticket]
    remove_deprecated_index_if_exists :two_factor_authenticators, [:user_id]
    remove_deprecated_index_if_exists :users, [:authenticator, :username]
  end

  private
  def remove_deprecated_index_if_exists(old_table_name, column_names)
    table_name = :"casino_#{old_table_name}"
    index_name = :"index_#{old_table_name}_on_#{column_names.join('_and_')}"
    if index_name_exists?(table_name, index_name, false)
      remove_index table_name, name: index_name
    else
      puts "index #{index_name} on #{table_name} not found"
    end
  end
end
