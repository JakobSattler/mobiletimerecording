class Zz5BeginEndTimes < ActiveRecord::Base

  attr_accessible :zz5_workdays_id, :begin, :end
  belongs_to :zz5_workday

end