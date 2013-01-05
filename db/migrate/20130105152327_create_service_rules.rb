class CreateServiceRules < ActiveRecord::Migration
  def change
    create_table :service_rules do |t|
      t.boolean :enabled, null: false, default: true
      t.integer :order, null: false, default: 10
      t.string :name, null: false
      t.string :url, null: false
      t.boolean :regex, null: false, default: false

      t.timestamps
    end

    add_index :service_rules, :url, unique: true
  end
end
