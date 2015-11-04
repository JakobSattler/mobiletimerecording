class CreateZz5SpecialHolidays < ActiveRecord::Migration
    def change
        create_table :zz5_special_holidays do |t|
        	t.belongs_to :user, :null => false
            t.date   :holiday_date
            t.float  :workday_factor, :default => 0
            t.string :holiday_name, :default => ""
           
        end
        add_index :zz5_special_holidays, ["user_id", "holiday_date"], :unique => true
    end
end