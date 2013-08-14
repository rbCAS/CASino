# This migration comes from casino (originally 20130203100015)
class CreateTwoFactorAuthenticators < ActiveRecord::Migration
  def change
    create_table :two_factor_authenticators do |t|
      t.integer :user_id, null: false
      t.string :secret, null: false

      t.timestamps
    end

    add_index :two_factor_authenticators, :user_id
  end
end
