class AddFavoriteTicketsZz5UserPreferences < ActiveRecord::Migration
    def up
        add_column :zz5_user_preferences, :favorite_tickets, :integer, :default => 10
    end

    def down
    	remove_column :zz5_user_preferences, :favorite_tickets
   	end
end