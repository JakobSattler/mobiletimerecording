class RenameEditDisplayWeekendColumnZz5UserPreferences < ActiveRecord::Migration
    def up
        change_column :zz5_user_preferences, :display_weekend, :integer, :default => 5
        rename_column :zz5_user_preferences, :display_weekend, :display_days
    end
end