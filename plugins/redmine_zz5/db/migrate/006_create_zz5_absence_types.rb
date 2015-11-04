class CreateZz5AbsenceTypes < ActiveRecord::Migration
  def change
    create_table :zz5_absence_types do |t|
      t.string :name
    end
  end
end
