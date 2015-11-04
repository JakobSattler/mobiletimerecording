class Zz5Employment < ActiveRecord::Base

  attr_accessible :id, :user_id, :employment, :start, :vacation_entitlement, :time_carry, :is_all_in
  belongs_to :user

end
