class AddDisplayWorktimesColumn < ActiveRecord::Migration
    def up
        add_column :zz5_user_preferences, :display_workdays, :integer, :default => 0
    end
end