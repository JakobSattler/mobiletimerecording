class RemoveZz5TimeDifferences < ActiveRecord::Migration
    def up
        drop_table :zz5_time_differences
    end
end