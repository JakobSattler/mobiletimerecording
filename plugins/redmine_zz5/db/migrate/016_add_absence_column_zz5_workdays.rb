class AddAbsenceColumnZz5Workdays < ActiveRecord::Migration
    def up
        add_column :zz5_workdays, :absences, :integer, :default => 0
    end
end