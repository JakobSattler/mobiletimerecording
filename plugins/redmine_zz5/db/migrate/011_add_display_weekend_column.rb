class AddDisplayWeekendColumn < ActiveRecord::Migration
    def up
        add_column :zz5_user_preferences, :display_weekend, :boolean, :default => 0
    end
end