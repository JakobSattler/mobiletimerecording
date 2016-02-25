class Zz5Workday < ActiveRecord::Base

  attr_accessible :user_id, :date, :begin, :end, :break, :target, :carry_forward, :carry_over, :absences
  belongs_to :user
  has_many :zz5_absences
  
end
