module WorkdaysHelper
  include Zz5GeneralHelper

  # returns true if the current user has an All-In contract else false
  def userHasAllInContract()

    employment = Zz5Employment.where(:user_id => @user.id).order(:start).last
    if (!employment.nil? && employment.is_all_in == true)
      return true
    else
      return false
    end

  end


  # returns the minimal date
  def get_min_date
    #Rails.logger.info "get_min_date called"

    if !@user.zz5_employments.first_or_create.start.nil?
      min_date = @user.zz5_employments.first_or_create.start.strftime("%Y-%m-%d");
    else
      min_date = ""
    end

    return min_date
  end

  # returns the maximal date
  def get_max_date
    #Rails.logger.info "get_max_date called"

    last_date = Zz5Workday.where(:user_id => @user.id).order(:date).last
    if !last_date.nil?
      week_start = last_date.date.beginning_of_week + 2.month
      max_date = week_start.strftime("%Y-%m-%d");
    else
      max_date = ""
    end

    return max_date
  end

  # returns the translations mapping from utilities
  def get_translations
    return Zz5GeneralUtil.get_translations
  end

  # returns true if there are time entries for the given week which don't belong to a ticket
  def hours_without_tickets_exist (week)

    hours = TimeEntry.where("user_id = ? AND tweek = ? AND issue_id IS NULL", @user.id.to_s, week)

    if (!hours.empty?)
      return true
    else
      return false
    end

  end

  # returns true if the user is allowd to edit time entries
  def is_user_allowed_to_edit(issue_id)

    project = Project.joins(:issues).where("issues.id = ?", issue_id).first

    if User.current.allowed_to?(:edit_own_time_entries, project) || User.current.allowed_to?(:edit_time_entries, project)
      #Rails.logger.info "User: " + User.current.to_s + " is allowed to edit tickets from project: " + project.to_s
      return true;
    end

    #Rails.logger.info "User: " + User.current.to_s + " is NOT allowed to edit tickets from project: " + project.to_s
    return false;
  end


  #returns true if the day is saturday or sunday
  def is_weekend(day)

    day_to_check = Date.parse(day).cwday

    if day_to_check == 6 || day_to_check == 7
    #if '6'.eql?(day) || 'sunday'.eql?(day)
      #Rails.logger.info "Day : " + day.to_s + " is a weekend day"
      return true;
    end

    #Rails.logger.info "Day : " + day.to_s + " is NO weekend day"
    return false;
  end

  # return Zz5GeneralUtil.is_holiday
  def is_holiday(this_date)
    return Zz5GeneralUtil.is_holiday(this_date)
  end


  # returns the vacation entitlement of an employment in format "HH:MM" of a day or an empty string
  def get_employment_vacation_entitlement(day)

    date =  @zz5_work_period.workdays[day].date
    Rails.logger.info "get_vacation_entitlement for date: " + date.to_s
    employment = Zz5Employment.where("user_id = ? AND start = ?", @user.id.to_s, date.to_s).first
    if employment.nil?
      Rails.logger.info "get_vacation_entitlement for date: " + date.to_s  + " returns ''"
      return ""
    end
    Rails.logger.info "get_vacation_entitlement for date: " + date.to_s + " returns '" + employment.vacation_entitlement.to_s + "'"
    return Zz5GeneralUtil.secondsToTime(employment.vacation_entitlement)
  end

  # returns the employment of a day in time format hh:mm
  def get_employment_for(day)
    date = @zz5_work_week.workdays[day].date
    Rails.logger.info "get_employment for date: " + date.to_s
    employment = Zz5Employment.where("user_id = ? AND start = ?", @user.id.to_s, date.to_s).first
    if employment.nil?
      Rails.logger.info "get_employment_for for date: " + date.to_s + " returns ''"
      return ""
    end
    Rails.logger.info "get_employment_for for date: " + date.to_s + " returns '" + employment.vacation_entitlement.to_s + " '"

    return Zz5GeneralUtil.secondsToTime(employment.employment)
  end

  # returns the time carry of a day in time format hh:mm
  def get_time_carry_for(day)
    date = @zz5_work_week.workdays[day].date
    Rails.logger.info "get_time_carry_for for date: " + date.to_s
    employment = Zz5Employment.where("user_id = ? AND start = ?", @user.id.to_s, date.to_s).first
    if employment.nil?
      Rails.logger.info "get_time_carry_for for date: " + date.to_s + " returns ''"
      return ""
    end
    Rails.logger.info "get_time_carry_for for date: " + date.to_s + " returns '" + employment.time_carry.to_s + " '"

    return Zz5GeneralUtil.secondsToTime(employment.time_carry)    
  end

  # returns the overtime allowance of a day in time format hh:mm
  def get_overtime_allowance_for(day)
    date = @zz5_work_period.workdays[day].date
    employment = Zz5Employment.where("user_id = ? AND start <= ?", @user.id, date).order(:start).last
    Rails.logger.info "get_overtime_allowance_for for date: " + date.to_s

    if employment.nil?
      employment = Zz5Employment.where("user_id = ? AND start > ?", @user.id, date).order(:start).first
    end

    if employment.overtime_allowance == 0 || date != date.beginning_of_month
      Rails.logger.info "get_overtime_allowance_for for date: " + date.to_s + " returns ''"
      return ""
    end
    
    Rails.logger.info "get_time_carry_for for date: " + date.to_s + " returns '" + employment.overtime_allowance.to_s + " '"
    return Zz5GeneralUtil.secondsToTime(employment.overtime_allowance)
  end

  ### functions to differentiate week and day view ###
  def is_week_view
    return @weekview
  end

  def is_day_view
    return !(@weekview)
  end

  def get_next_url_title
    if is_day_view
        return l(:zz5_next_day)
    else
        return l(:zz5_next_cw)
    end
  end

  def get_prev_url_title
    if is_day_view
        return l(:zz5_prev_day)
    else
        return l(:zz5_prev_cw)
    end
  end

  # switch to day view
  def get_day_title_url(date)
        return "/zz5/" + @year + "/" + @week + "/" + date.cwday.to_s
  end

  # Returns a collection of activities for a select field.  time_entry
  # is optional and will be used to check if the selected TimeEntryActivity
  # is active.
  def activity_collection_for_select_options(time_entry=nil, project=nil)
    project ||= @project
    if project.nil?
      activities = TimeEntryActivity.shared.active
    else
      activities = project.activities
    end

    collection = []
    if time_entry && time_entry.activity && !time_entry.activity.active?
      collection << [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ]
    else
      collection << [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ] unless activities.detect(&:is_default)
    end
    activities.each { |a| collection << [a.name, a.id] }
    collection
  end

end
