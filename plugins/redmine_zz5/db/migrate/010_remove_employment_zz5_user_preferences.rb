class RemoveEmploymentZz5UserPreferences < ActiveRecord::Migration
    def up
        remove_column :zz5_user_preferences, :employment
    end
end