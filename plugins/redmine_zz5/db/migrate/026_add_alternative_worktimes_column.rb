class AddAlternativeWorktimesColumn < ActiveRecord::Migration
  def up
    add_column :zz5_user_preferences, :alternative_worktimes, :integer, :default => 0
  end
end