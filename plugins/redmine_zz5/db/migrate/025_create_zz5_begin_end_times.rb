class CreateZz5BeginEndTimes < ActiveRecord::Migration
  def change
    create_table :zz5_begin_end_times do |t|
      t.belongs_to  :zz5_workdays
      t.time        :begin
      t.time        :end
    end
  end
end