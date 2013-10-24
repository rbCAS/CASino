# In order to support pre-2.0 installations of CASino that included CASinoCore,
# we must rebuild the un-namespaced CASinoCore schema so that we can upgrade
class CreateCoreSchema < ActiveRecord::Migration
  CoreTables = %w{login_tickets proxy_granting_tickets proxy_tickets service_rules service_tickets ticket_granting_tickets two_factor_authenticators users}

  def up
    CoreTables.each do |table_name|
      if !ActiveRecord::Base.connection.table_exists? table_name
        send "create_#{table_name}"
      end
    end
  end

  def down
    # No-op
    # Handled by 20130809135401_rename_base_models.rb
  end

  def create_login_tickets
    create_table :login_tickets do |t|
      t.string :ticket, :null => false

      t.timestamps
    end
    add_index :login_tickets, :ticket, :unique => true
  end

  def create_proxy_granting_tickets
    create_table :proxy_granting_tickets do |t|
      t.string  :ticket,       :null => false
      t.string  :iou,          :null => false
      t.integer :granter_id,   :null => false
      t.string  :pgt_url,      :null => false
      t.string  :granter_type, :null => false

      t.timestamps
    end
    add_index :proxy_granting_tickets, :ticket, :unique => true
    add_index :proxy_granting_tickets, :iou, :unique => true
    add_index :proxy_granting_tickets, [:granter_type, :granter_id], :name => "index_proxy_granting_tickets_on_granter", :unique => true
  end

  def create_proxy_tickets
    create_table :proxy_tickets do |t|
      t.string  :ticket,                                      :null => false
      t.string  :service,                                     :null => false
      t.boolean :consumed,                 :default => false, :null => false
      t.integer :proxy_granting_ticket_id,                    :null => false

      t.timestamps
    end
    add_index :proxy_tickets, :ticket, :unique => true
    add_index :proxy_tickets, :proxy_granting_ticket_id
  end

  def create_service_rules
    create_table :service_rules do |t|
      t.boolean :enabled, :default => true,  :null => false
      t.integer :order,   :default => 10,    :null => false
      t.string  :name,                       :null => false
      t.string  :url,                        :null => false
      t.boolean :regex,   :default => false, :null => false

      t.timestamps
    end
    add_index :service_rules, :url, :unique => true
  end

  def create_service_tickets
    create_table :service_tickets do |t|
      t.string  :ticket,                                      :null => false
      t.string  :service,                                     :null => false
      t.integer :ticket_granting_ticket_id
      t.boolean :consumed,                 :default => false, :null => false
      t.boolean :issued_from_credentials,  :default => false, :null => false

      t.timestamps
    end
    add_index :service_tickets, :ticket, :unique => true
    add_index :service_tickets, :ticket_granting_ticket_id
  end

  def create_ticket_granting_tickets
    create_table :ticket_granting_tickets do |t|
      t.string  :ticket,                                                :null => false
      t.string  :user_agent
      t.integer :user_id,                                               :null => false
      t.boolean :awaiting_two_factor_authentication, :default => false, :null => false
      t.boolean :long_term,                          :default => false, :null => false

      t.timestamps
    end
    add_index :ticket_granting_tickets, :ticket, :unique => true
  end

  def create_two_factor_authenticators
    create_table :two_factor_authenticators do |t|
      t.integer :user_id,                    :null => false
      t.string  :secret,                     :null => false
      t.boolean :active,  :default => false, :null => false

      t.timestamps
    end
    add_index :two_factor_authenticators, :user_id
  end

  def create_users
    create_table :users do |t|
      t.string  :authenticator,   :null => false
      t.string  :username,        :null => false
      t.text    :extra_attributes

      t.timestamps
    end
    add_index :users, [:authenticator, :username], :unique => true
  end
end