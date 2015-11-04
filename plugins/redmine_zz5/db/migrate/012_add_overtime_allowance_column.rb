class AddOvertimeAllowanceColumn < ActiveRecord::Migration
    def up
        add_column :zz5_employments, :overtime_allowance, :integer, :default => 0
    end
end