class CreateZz5Employments < ActiveRecord::Migration
    def change
        create_table :zz5_employments do |t|
            t.belongs_to :user
            t.date :start
            t.float :employment, :default => 0
	        t.integer :vacation_entitlement, :limit => 8, :default => 0
	        t.integer :time_carry
	        t.boolean :is_all_in
        end
    end
end
