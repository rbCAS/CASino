class RemoveUsernameFromLoginAttempts < ActiveRecord::Migration
  def up
    remove_column :casino_login_attempts, :username
    change_column_null :casino_login_attempts, :user_id, false
  end

  def down
    add_column :casino_login_attempts, :username, :string
    change_column_null :casino_login_attempts, :user_id, true
  end
end
