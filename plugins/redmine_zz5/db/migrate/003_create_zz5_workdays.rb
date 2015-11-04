class CreateZz5Workdays < ActiveRecord::Migration
    def change
        create_table :zz5_workdays do |t|
            t.belongs_to :user, :null => false
            t.date :date
            t.time :begin
            t.time :end
            t.time :break
            t.time :target, :default => "00:00:00"
        end
        add_index :zz5_workdays, ["user_id", "date"], :unique => true
    end
end
