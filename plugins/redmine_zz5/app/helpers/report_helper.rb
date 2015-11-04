module ReportHelper

  include Zz5GeneralHelper

  # returns the absence duration as a time object for the given absence name
  # returns nil if the result set (absence_rs) is nil or the result set doesn't contain this absence type name
  def get_absence_duration(absence_rs, absence_name)
    if absence_rs.nil? or absence_rs.name != absence_name
      return nil
    end

    return absence_rs.duration
  end

  # adds  given seconds (target working time, actual working time, absence times) for
  # the given work sum array
  #
  # the work sum array must consist of the following six entries:
  # 0 ... target time
  # 1 ... actual time
  # 2 ... absence vacation
  # 3 ... absence sick
  # 4 ... absence special vacation
  # 5 ... absence care
  # 6 ... total time: actual + all absences
  def add_work_time(work_sum, target_seconds, actual_seconds, absence_rs, day)

    Rails.logger.info "get_absence_in_days: " + get_absence_in_days(day, get_absence_duration(absence_rs, "zz5_absence_vacation")).to_s
    work_sum[Zz5Constants::TARGET_TIME]     = work_sum[Zz5Constants::TARGET_TIME] + target_seconds
    work_sum[Zz5Constants::ACTUAL_TIME]     = work_sum[Zz5Constants::ACTUAL_TIME] + actual_seconds
    work_sum[Zz5Constants::ABS_VAC]         = work_sum[Zz5Constants::ABS_VAC] + convert_date_time_to_seconds(get_absence_duration(absence_rs, "zz5_absence_vacation"))
    work_sum[Zz5Constants::ABS_SICK]        = work_sum[Zz5Constants::ABS_SICK] + convert_date_time_to_seconds(get_absence_duration(absence_rs, "zz5_absence_sick"))
    work_sum[Zz5Constants::ABS_SPECIAL_VAC] = work_sum[Zz5Constants::ABS_SPECIAL_VAC] + convert_date_time_to_seconds(get_absence_duration(absence_rs, "zz5_absence_special_vacation"))
    work_sum[Zz5Constants::ABS_CARE]        = work_sum[Zz5Constants::ABS_CARE] + convert_date_time_to_seconds(get_absence_duration(absence_rs, "zz5_absence_care"))
    work_sum[Zz5Constants::ABS_VAC_DAY]     = work_sum[Zz5Constants::ABS_VAC_DAY] + get_absence_in_days(day, get_absence_duration(absence_rs, "zz5_absence_vacation"))
    work_sum[Zz5Constants::ABS_COMP_TIME]   = work_sum[Zz5Constants::ABS_COMP_TIME] + convert_date_time_to_seconds(get_absence_duration(absence_rs, "zz5_absence_comp_time"))
  end

  # checks if the given date is the last day of a month
  def is_last_day_of_month(mydate)
    return mydate.month != mydate.next_day.month
  end

  # checks if the given date is the last day of a year
  def is_last_day_of_year(mydate)
    return (mydate.month == 12 and mydate.day == 31)
  end

  # calculates the carry for the given user ID until the given report start date
  # returns the carry in seconds
  def get_time_carry(user_id, report_start_date)
    return Zz5Workday.where("user_id = ? AND date = ?", user_id, report_start_date).first.carry_forward
  end

  # returns the minimal dates hash
  def get_min_dates
    #Rails.logger.info "get_min_date called"

    min_dates = {}

    @users.each do |user|
      #Rails.logger.info "get_min_dates, user id: " + user.id.to_s + ", user: " + user.to_s
      employment = Zz5Employment.where("user_id = ?", user.id.to_s).first_or_create
      if !employment.start.nil?
        min_dates[user.id.to_i] = employment.start.strftime("%Y-%m-%d")
        Rails.logger.info "user: " + user.id.to_s + "employment start: " + employment.start.strftime("%Y-%m-%d").to_s
      else
        min_dates[user.id.to_i] = 0
      end
    end

    return min_dates
  end

  # returns the maximal dates hash
  def get_max_dates
    #Rails.logger.info "get_max_date called"
    max_dates = {}
    @users.each do |user|
      #Rails.logger.info "get_max_dates, user: " + user.to_s

      last_date = Zz5Workday.where(:user_id => user.id).order(:date).last
      if !last_date.nil?
        last_date = last_date.date - 1
        max_dates[user.id.to_i] = (last_date).strftime("%Y-%m-%d")
      else
        max_dates[user.id.to_i] = 0
      end
    end

    return max_dates
  end

  # returns the absence in days
  def get_absence_in_days(day, duration)

    #Rails.logger.info "get_absence_in_days, day: " + day.to_s + ", duration: " + duration.to_s
    if day.nil? or duration.nil?
      Rails.logger.info "get_absence_in_days day or duration is nil"
      return 0.0
    end

    formatted_duration = duration.strftime("%H:%M")
    formatted_day = day.strftime("%Y-%m-%d")


    Rails.logger.info "get_absence_in_days for day: " + formatted_day.to_s + ", duration: " + formatted_duration.to_s

    #get vacation until this day
    employment = Zz5Employment.where("user_id = ? AND start <= ?", @user_id.to_s, formatted_day.to_s).order("start ASC").last

    if employment.nil?
      Rails.logger.info "employment is nil"
      return 0.0
    end

    result = (Zz5GeneralUtil.timeToSeconds(formatted_duration) / (employment.employment / 5.0) )
    
    if(result.nil?)
      result = 0.0
    end

    Rails.logger.info "get_absence_in_days result: " + result.to_s
    return result.round(2)
  end


end
