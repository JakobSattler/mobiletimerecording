class CreateZz5RemovedTickets < ActiveRecord::Migration
  def change
    create_table :zz5_removed_tickets do |t|
      t.integer :user_id
      t.integer :issue_id
    end
  end
end
