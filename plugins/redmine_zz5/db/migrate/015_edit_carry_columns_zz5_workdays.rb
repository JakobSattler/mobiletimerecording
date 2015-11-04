class EditCarryColumnsZz5Workdays < ActiveRecord::Migration
    def up
        change_column :zz5_workdays, :carry_over, :integer, :default => 0
        change_column :zz5_workdays, :carry_forward, :integer, :default => 0
    end
end