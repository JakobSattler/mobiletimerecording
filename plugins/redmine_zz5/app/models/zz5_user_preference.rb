class Zz5UserPreference < ActiveRecord::Base

  attr_accessible :employment, :work_start, :end_work, :break_duration, :work_days, :favorite_tickets, :display_days, :ticket_order_by_id, :alternative_worktimes
  belongs_to :user

end
