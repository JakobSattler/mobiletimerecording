class Zz5SpecialHoliday < ActiveRecord::Base

  attr_accessible :user_id, :holiday_date, :workday_factor, :holiday_name
  belongs_to :user

end
