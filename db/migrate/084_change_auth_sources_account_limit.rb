class ChangeAuthSourcesAccountLimit < ActiveRecord::Migration
  def self.up
    change_column :auth_sources, :mtr_account, :string, :limit => nil
  end

  def self.down
    change_column :auth_sources, :mtr_account, :string, :limit => 60
  end
end
