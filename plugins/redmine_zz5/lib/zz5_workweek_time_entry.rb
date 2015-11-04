class Zz5WorkweekTimeEntry

  attr_reader   :time_entries

  def initialize(year, week, user, pid, load_time_entries)
    Rails.logger.info "called initialize with year: " + year.to_s + ", week: " + week.to_s + ", user: " + user.to_s + ", pid: " + pid.to_s
    @pid = pid
    @user = user
    @first_day = Date.commercial(year.to_i, week.to_i, 1)
    @last_day = Date.commercial(year.to_i, week.to_i, 7)

    if load_time_entries
      @time_entries = init_time_entries
    else
      @time_entries = {}
    end

  end


  def init_time_entries

    time_entries = {}
    issues =  Issue.where("project_id = ? AND ((status_id != 3 AND status_id != 5 AND status_id != 6 AND status_id != 8) OR closed_on >= ?) AND created_on <= ?", @pid, @first_day, @last_day)

    issues.each do | issue |
      workdays = {}
      Zz5Workperiod.get_week_dates(@first_day).each do |label, wdate|
       workdays[label] = TimeEntry.joins(:issue).where(['time_entries.project_id = ? AND time_entries.user_id = ? AND spent_on = ? AND time_entries.issue_id = ?', @pid.to_s, @user.id.to_s, wdate.to_s, issue.id.to_s])
      end
      
      time_entries[issue] = workdays
    end

    return time_entries;

  end




end
