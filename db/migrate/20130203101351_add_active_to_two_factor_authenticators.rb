class AddActiveToTwoFactorAuthenticators < ActiveRecord::Migration
  def change
    add_column :two_factor_authenticators, :active, :boolean, null: false, default: false
  end
end
