class CreateLoginAttempts < ActiveRecord::Migration
  def change
    create_table :casino_login_attempts do |t|
      t.integer :user_id, null: true
      t.string :username, null: false
      t.boolean :successful, default: false

      t.string  :user_ip
      t.text  :user_agent

      t.timestamps
    end
  end
end
