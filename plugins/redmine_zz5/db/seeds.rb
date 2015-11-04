# ruby encoding: utf-8
#
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#


#
# add absences
#
absence_list = [
  [ "zz5_absence_sick" ],
  [ "zz5_absence_care" ],
  [ "zz5_absence_special_vacation" ],
  [ "zz5_absence_vacation" ],
  [ "zz5_absence_comp_time" ]
]

absence_list.each do |absence|
	Zz5AbsenceType.find_or_create_by_name( :name => absence[0] )
end


#
# add employments for default users
#
# user = User.where(:login => "Administrator").first
#if user.nil?
#    Zz5Employment.create( :user_id => user.id, :start => "2013-01-01", :employment => 138600, :vacation_entitlement => 10000 )
#end

#
# add recurring special holidays for all users
#
holiday = Zz5SpecialHoliday.where(:holiday_name => "Weihnachten").first
if holiday.nil?
    Zz5SpecialHoliday.create( :user_id => -1, :holiday_date => "0000-12-24", :holiday_name => "Weihnachten", :workday_factor => 0.5 )
end

holiday = Zz5SpecialHoliday.where(:holiday_name => "Silvester").first
if holiday.nil?
    Zz5SpecialHoliday.create( :user_id => -1, :holiday_date => "0000-12-31", :holiday_name => "Silvester", :workday_factor => 0.5)
end
