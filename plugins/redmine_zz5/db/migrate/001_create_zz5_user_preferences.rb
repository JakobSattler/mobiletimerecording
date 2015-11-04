class CreateZz5UserPreferences < ActiveRecord::Migration
    def change
        create_table :zz5_user_preferences do |t|
            t.belongs_to :user
            t.time   :work_start, :default => "09:00:00"
            t.time   :end_work, :default => "17:00:00"
            t.time   :break_duration, :default => "00:30:00"
            t.time   :employment, :default => "38:30:00"
            t.string :work_days, :default => "1111100"
        end
    end
end
