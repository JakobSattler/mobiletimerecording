#
# General Utility Class
#
class Zz5GeneralUtil

  #checkf if the time entry is valid like "0.0" or "00.00"
  def self.is_valid_time_entry(time_entry)
    if m = /^([0-9]{1,2}\.[0-9]{1,2})$/.match(time_entry)
      if  time_entry.to_f <= 24.0 && time_entry.to_f > 0.0
        return true
      else
        return false
      end
      return true
    end
    return false

  end

  # checks if time string is a string like "HH:MM"
  def self.is_valid_time(time_string)
    if m = /^[0-9][0-9]:[0-9][0-9]$/.match(time_string)
      return true
    end
    return false
  end

  # checks if vacation string is a float like "1,5" with a max of 3 digits before the comma and 4 digits after the comma
  def self.isValidVacation(vacation_string)
    if m = /^\d+(\.\d+)?$/.match(vacation_string)
      return true
    end
    return false
  end

  # checks if time carry string is a string like "-HHH:MM" where up to three digits are reserved for hours
  def self.isValidTimeCarry(time_string)
    if m = /^-?[0-9]{1,4}(:[0-5][0-9])?$/.match(time_string)
      return true
    end
    return false
  end

  # checks if time string is a string like "HH:MM" with a maximum of 38:30
  def self.isValidEmployment(time_string)
    if m = /(^[1-2]?[0-9]:[0-5][0-9]$)|(^[3][0-7]:[0-5][0-9]$)|(^[3][8]:[0-3][0]$)/.match(time_string)
      return true
    end
    return false
  end

  # checks if date string is a string like "dd-mm-yyyy"
  def self.isValidDate(date_string)
    if m = /^([0][1-9]|[1][0-9]|[2][0-9]|[3][0,1])-([0][1-9]|[1][0-2])-[0-9]{4}$/.match(date_string)
      return true
    end
    return false
  end

  # checks if time string is a string like "HH:MM"
  def self.isValidOvertime(overtime_string)
    if m = /(^[1-2]?[0-9]:[0-5][0-9]$)|(^[3][0-7]:[0-5][0-9]$)|(^[3][8]:[0-3][0]$)/.match(overtime_string)
      return true
    end
    return false
  end

  # checks if the time frame is correct ( (end - begin - break) > 0 )
  def self.is_valid_time_frame(time_begin, time_end, time_break)

    #check for correct time strings
    if is_valid_time(time_begin) &&is_valid_time(time_end) && is_valid_time(time_break)

      t_begin = Time.parse(time_begin).to_i
      t_end = Time.parse(time_end).to_i
      t_break = (Time.parse(time_break).to_i - Time.parse("00:00").to_i)

      if (( t_end - t_begin - t_break) >= 0)
        return true
      end
    end

    return false

  end

  # converts the given seconds to a human-readable "H:M" format where hours can be more than 24 hours
  def self.secondsToTime(seconds)
    sec = seconds
    appendMinus = false

    if seconds < 0
      sec = -1 * seconds
      appendMinus = true
    end

    hours = (sec / 3600).floor
    minutes = ((sec.modulo(3600))/60)

    minutes = minutes.round



    h = hours;
    m = minutes;

    # add 0 padding
    if hours < 10
       h = "0" + hours.to_s
    end

    # add 0 padding
    if minutes < 10
      m = "0" + minutes.to_s
    end

    if minutes == 60
      m = "59"
    end

    result = h.to_s + ":" + m.to_s

    if appendMinus
      return "-" + result
    end

    return result
  end

  # converts the given time with format ("hh:mm") to seconds
  def self.timeToSeconds(time)

    appendMinus = false

    if time.nil? || time == 0 || time == ""
      return 0
    end

    if time.start_with?("-")
      appendMinus = true
    end

    time_parts = time.split(":")

    hours = time_parts[0].to_i.abs
    minutes = time_parts[1].to_i

    seconds = hours * 3600 + minutes * 60

    if appendMinus
      seconds = seconds * -1
    end

    return seconds
  end


  # converts the given seconds to a float of days (a day according to the employment scope)
  # eg. employment scope is 20 hours, one day is 4 hours
  def self.secondsToWorkdays(seconds, work_week)

    work_day = work_week.to_f / 5.0

    if seconds != 0
      days = (seconds.to_f / work_day.to_f).round(4)
    else
      days = 0
    end

    Rails.logger.info "secondsToWorkdays - vacation days: " + days.to_s + " for seconds: " + seconds.to_s

    return days
  end

  # converts the given days as float (eg 1.5 days) to seconds
  def self.workdaysToSeconds(days, work_week)

    work_day = work_week.to_f / 5.0

    seconds = (days.to_f * work_day.to_f).floor

    Rails.logger.info "workdaysToSeconds - vacation days: " + days.to_s + " for seconds: " + seconds.to_i.to_s

    return seconds.to_i
  end

  #converts hours (e.g. 1.5 ) to a human readable time string (e.g 01:30)
  def self.hoursToTime(hours)
    Rails.logger.info "hoursToTime called with: " + hours.to_f.to_s
    
    if hours.nil?
      hours = 0
    end 

    seconds = hours.to_f * 3600
    #Rails.logger.info "hoursToTime seconds: " + seconds.to_s
    result = Zz5GeneralUtil.secondsToTime(seconds)
    #Rails.logger.info "hoursToTime result: " + result.to_s

    
    return result
  end

  #converts a time string (e.g 01:00) to a float value in hours (e.g 1.5)
  def self.timeToHours(time)
    #split string and calculate worked hours
    split_time = time.split(':')
    value = split_time.first.to_f
    value += split_time.last.to_f / 60
    
    Rails.logger.info "timeToHours : " + time.to_s + " converted to: " + value.to_s
    return value
  end


  def self.get_translations

    result = Hash.new
    result["zz5_weekly_time_difference"] = I18n.translate(:zz5_weekly_time_difference)
    result["zz5_daily_time_difference"] = I18n.translate(:zz5_daily_time_difference)
    result["zz5_label_carry"] = I18n.translate(:zz5_label_carry)
    result["hours"] = I18n.translate(:field_hours)
    result["days"] = I18n.translate(:label_day_plural)
    return result
  end


  # Determine if the given date is a holiday in Austria.
  #
  # the method returns 0 if the it is a holiday and > 0 if it is a working day
  # the returned factor can be multiplied with the daily working time
  def self.is_holiday(this_date)

    if this_date == nil
      return 0
    end

    if this_date.saturday? || this_date.sunday? || this_date.holiday?(:at)
      return 0
    end

    is_user_holiday = Zz5SpecialHoliday.find_by_user_id_and_holiday_date(User.current.id,this_date)
    is_all_user_holiday = Zz5SpecialHoliday.find_by_user_id_and_holiday_date(-1,this_date)
    recurring_date = Date.new(1900, this_date.month, this_date.day)
    is_all_user_holiday_recurring = Zz5SpecialHoliday.where(:user_id => -1, :holiday_date => recurring_date).first

    if is_user_holiday != nil
      return is_user_holiday.workday_factor

    elsif is_all_user_holiday != nil
      return is_all_user_holiday.workday_factor

    elsif is_all_user_holiday_recurring != nil
      return is_all_user_holiday_recurring.workday_factor

    else
      return 1

    end
  end

  # Converts a string of format "dd-mm-yyyy" to a dateTime of format "yyyy-mm-dd"
  def self.stringToDate(date_string)

    date_parts = date_string.split("-")
    day = date_parts[0]
    month = date_parts[1]
    year = date_parts[2]

    new_date_string = year + "-" + month + "-" + day

    return new_date_string.to_date
  end

  def self.migrateData
    puts "start migration"
    users = User.all

    users.each do |user|
      puts "migrating data for user: #{user.id}"
      workdays = Zz5Workday.where("user_id = ? AND begin IS NOT NULL", user.id)

      workdays.each do |workday|
      # creates the begin times for the given wday
        id = workday.id
        #Rails.logger.info "create_begin_end_times, workdays id: " + id.to_s
        #Rails.logger.info "create_begin_end_times, t_begin: " + time_begin.to_s
        #Rails.logger.info "create_begin_end_times, t_end: " + time_end.to_s
        time_begin_in_s = Zz5GeneralUtil.timeToSeconds(workday.begin.strftime("%H:%M"))
        time_end_in_s = Zz5GeneralUtil.timeToSeconds(workday.end.strftime("%H:%M"))
        time_break_in_s = Zz5GeneralUtil.timeToSeconds(workday.break.strftime("%H:%M"))

        worked = time_end_in_s - time_begin_in_s - time_break_in_s

        be_times_first = Zz5BeginEndTimes.new(:zz5_workdays_id => id, :begin => workday.begin, :end => Zz5GeneralUtil.secondsToTime(time_begin_in_s + worked))
        if be_times_first.save
          Rails.logger.info "create_begin_end_times, new begin end times successful!!! " + be_times_first.id.to_s + " " + be_times_first.begin.to_s + " " + be_times_first.end.to_s
        else
          Rails.logger.info "create_begin_end_times, new begin end times failed!!!"
        end

        be_times_second = Zz5BeginEndTimes.new(:zz5_workdays_id => id, :begin => workday.end, :end => workday.end)
        if be_times_second.save
          Rails.logger.info "create_begin_end_times, new begin end times successful!!! " + be_times_second.id.to_s + " " + be_times_second.begin.to_s + " " + be_times_second.end.to_s
        else
          Rails.logger.info "create_begin_end_times, new begin end times failed!!!"
        end
      end
    end
    puts "dropping begin, end, break columns from zz5_workdays"
    ActiveRecord::Migration.remove_column :zz5_workdays, :begin
    ActiveRecord::Migration.remove_column :zz5_workdays, :end
    ActiveRecord::Migration.remove_column :zz5_workdays, :break

    puts "migration finished"
  end
end
