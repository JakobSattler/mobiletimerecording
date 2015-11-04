class AddFavoriteTicketOrderColumn < ActiveRecord::Migration
    def up
        add_column :zz5_user_preferences, :favorite_ticket_order, :integer, :default => 0
    end
end