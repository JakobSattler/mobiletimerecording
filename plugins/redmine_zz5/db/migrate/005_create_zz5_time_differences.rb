class CreateZz5TimeDifferences < ActiveRecord::Migration
    def change
        create_table :zz5_time_differences do |t|
            t.belongs_to :user
            t.date :week_start
            t.integer :actual, :limit => 8, :default => 0
            t.integer :target, :limit => 8, :default => 0
            t.integer :vacation, :limit => 8, :default => 0
            t.integer :special_leave, :limit => 8, :default => 0
            t.integer :care_leave, :limit => 8, :default => 0
            t.integer :sick_leave, :limit => 8, :default => 0
        end
        add_index :zz5_time_differences, ["user_id", "week_start"], :unique => true
    end
end
