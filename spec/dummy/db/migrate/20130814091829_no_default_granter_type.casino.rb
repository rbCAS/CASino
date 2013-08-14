# This migration comes from casino (originally 20121225231713)
class NoDefaultGranterType < ActiveRecord::Migration
  def up
    change_column_default :proxy_granting_tickets, :granter_type, nil
  end
end
