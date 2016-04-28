class MtrTestController < ApplicationController
  def mtr_test
    @user = User.current
    @year = params[:year]
    @week = params[:week]
    @day = params[:day]
    @curr_date = Date.commercial(@year.to_i, @week.to_i, @day.to_i)
    Rails.logger.info 'date: ' + @curr_date.to_s
    zz5_workdays_id = Zz5Workday.where("user_id = ? and date = ?", @user.id, @curr_date).first.id
    zz5_begin_end_times = Zz5BeginEndTimes.where("zz5_workdays_id = ?", zz5_workdays_id).first

    @test = params[:test]
    Rails.logger.info 'begin: ' + zz5_begin_end_times.begin.to_s
    Rails.logger.info 'end: ' + zz5_begin_end_times.end.to_s

    params[:test] = @curr_date

    employment_data = Zz5Employment.where(:user_id => @user.id).order('start ASC').first
  end
end