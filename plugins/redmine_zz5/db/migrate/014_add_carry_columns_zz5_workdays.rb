class AddCarryColumnsZz5Workdays < ActiveRecord::Migration
    def up
        add_column :zz5_workdays, :carry_over, :time, :default => "00:00:00"
        add_column :zz5_workdays, :carry_forward, :time, :default => "00:00:00"
    end
end