class AddDisplayProjectTreeColumn < ActiveRecord::Migration
    def up
        add_column :zz5_user_preferences, :display_projects, :boolean, :default => 1
    end
end