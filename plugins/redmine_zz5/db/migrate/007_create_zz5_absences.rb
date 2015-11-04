class CreateZz5Absences < ActiveRecord::Migration
  def change
    create_table :zz5_absences do |t|
      t.belongs_to :zz5_workday, :null => false
      t.belongs_to :zz5_absence_type
      t.time :duration, :default => "00:00:00"
    end
  end
end
