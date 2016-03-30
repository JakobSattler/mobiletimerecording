class MtrWorkdaysController < ApplicationController
  unloadable

  before_filter :set_cache_buster

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end


  # redirect user to current week and year
  def index
    if User.current.allowed_to?(:view_zz5, nil, :global => true)
      curr_date = Date.today
      first_day_week = curr_date.beginning_of_week
      week = first_day_week.cweek.to_s
      year = first_day_week.strftime("%Y")
      if User.current.zz5_user_pref.alternative_worktimes == 1
        day = curr_date.wday
        # our workweek ends with sunday = 7 but wday returns sunday = 0
        if day == 0
          day = 7
        end
        redirect_to '/zz5/' + year + '/' + week + '/' + day.to_s
      elsif User.current.zz5_user_pref.display_days != 1
        redirect_to '/zz5/' + year + '/' + week
      else
        day = curr_date.wday
        # our workweek ends with sunday = 7 but wday returns sunday = 0
        if day == 0
          day = 7
        end
        redirect_to '/zz5/' + year + '/' + week + '/' + day.to_s
      end
    else
      render_403
    end
  end

  # show the workday input page
  def mtr_show
    #Rails.logger.info "WorkdayController, show"
    if User.current.allowed_to?(:view_zz5, nil, :global => true)
      @user = User.current
      @year = params[:year]
      @week = params[:week]
      @month = params[:month]
      @day  = params[:day]
      @date = nil

      @begin = params[:begin]
      @end = params[:end]
      @break = params[:break]


      if @year == nil
        Rails.logger.info "today: " + Date.today.to_s
        @date = Date.today
        params[:year] = @date.year.to_s
        params[:month] = @date.mon.to_s
        params[:day] = @date.mday.to_s
      else
        @date = Date.new(@year.to_i, @month.to_i, @day.to_i);
      end
      params[:date_label] = @date.strftime("%d.%m.%Y")
      params[:date] = "#{@date.mday}.#{@date.mon}.#{@date.year}"



      Rails.logger.info "@date: " + @date.to_s
      Rails.logger.info "@year: " + @year.to_s
      Rails.logger.info "@month: " + @month.to_s
      Rails.logger.info "@week: " + @week.to_s
      Rails.logger.info "@day: " + @day.to_s
      Rails.logger.info "@begin: " + @begin.to_s
      Rails.logger.info "@end: " + @end.to_s
      Rails.logger.info "@break: " + @break.to_s

      zz5_workdays_id = Zz5Workday.where("user_id = ? and date = ?", @user.id, @date).first.id
      zz5_begin_end_times = Zz5BeginEndTimes.where("zz5_workdays_id = ?", zz5_workdays_id).first

      if zz5_begin_end_times != nil
        params[:begin] = zz5_begin_end_times.begin.strftime("%H:%M")
        params[:end] = zz5_begin_end_times.end.strftime("%H:%M")
      else
        params[:begin] = "00:00"
        params[:end] = "00:00"
      end
    else
      render_403
    end

  end

  def load_data

    @year = params[:year]
    @week = params[:week]
    @day  = params[:day]
    @user = User.current

    Rails.logger.info "year: " + @year.to_s

    #"wednesday" == Date.commercial(2015, 4, 3).strftime("%A").downcase
    if @day == -1
      @curr_date = Date.commercial(@year.to_i, @week.to_i, 1)
      @weekview = true
      Rails.logger.info "zz5_workdays_controller, load_data, weekview"
    else
      @curr_date = Date.commercial(@year.to_i, @week.to_i, @day.to_i)
      @weekview = false
      Rails.logger.info "zz5_workdays_controller, load_data, no weekview"
    end

    employment_data = Zz5Employment.where(:user_id => @user.id).order('start ASC').first
    Rails.logger.info "zz5_workdays_controller, load_data, employment_data: " + employment_data.start.beginning_of_week.to_s
    Rails.logger.info "zz5_workdays_controller, load_data, curr_date: " + @curr_date.to_s

    if !employment_data.nil? && employment_data.start.beginning_of_week <= @curr_date && @curr_date <= (Date.today + 6.months)
      @user.zz5_user_pref

      if @user.zz5_user_pref.alternative_worktimes == true
        @weekview = false
      end

      @absence_types = Zz5AbsenceType.select("id, name")

      from = @curr_date
      to = get_week_period_end(from)
      Rails.logger.info "workdays_controller, load_data from: " + from.to_s
      Rails.logger.info "workdays_controller, load_data to: " + to.to_s
      init_controller(from, to)
      @parent_projects = @zz5_work_period.get_parent_projects

      if @weekview
        @vacation = @zz5_work_period.get_vacation_entitlement_in_days(to)
      else
        @vacation = @zz5_work_period.get_vacation_entitlement_in_days(from + 1.days)
      end

      favorite_issues(@user.zz5_user_pref.favorite_tickets)

      respond_to do |format|
        format.json { render :partial => "workdays/data" }
      end

    else
      #date is before first employment
      #Rails.logger.info "date is before first employment: " + curr_date.to_s
      render_403
    end
  end

  def save_single_worktime

    @user = User.current

    if @user.allowed_to?(:view_zz5, nil, :global => true)
      date = params[:date]
      type = params[:type]
      id = params[:id].to_i
      time_begin = (params[:begin]).to_s
      time_end = (params[:end]).to_s
      time_break = (params[:break]).to_s

      Rails.logger.info "save_day, Begin: " + time_begin.to_s
      Rails.logger.info "save_day, End: " + time_end.to_s
      Rails.logger.info "save_day, Date: " + date.to_s
      Rails.logger.info "save_day, ID: " + id.to_s
      init_controller(date.to_date, 0)

      @be_id = @zz5_work_period.set_single_workday_data(id, type, time_begin, time_end, time_break, date, @user.id)

      if @be_id == -1
        raise "error"
      end

      # manual call of calculate carries necessary to account for changed worktimes
      @zz5_work_period.calculate_carries
      @zz5_work_period.save_work_period
      @carry = Zz5GeneralUtil.secondsToTime(@zz5_work_period.workdays[0].carry_over)
      Rails.logger.info "save_day, @carry: " + @carry.to_s
      Rails.logger.info "save_day, @be_id: " + @be_id.to_s
      @vacation = @zz5_work_period.get_vacation_entitlement_in_days(date.to_date + 1.days)

      respond_to do |format|
        format.json { render :partial => "workdays/saved_msg" }
      end
    else
      render_403
    end
  end

  def save_multiple_worktime

    @user = User.current

    if @user.allowed_to?(:view_zz5, nil, :global => true)
      date = params[:date]
      id = params[:id].to_i
      time_begin = (params[:begin]).to_s
      time_end = (params[:end]).to_s
      time_break = (params[:break]).to_s

      Rails.logger.info "save_day, Begin: " + time_begin.to_s
      Rails.logger.info "save_day, End: " + time_end.to_s
      Rails.logger.info "save_day, Date: " + date.to_s
      init_controller(date.to_date, 0)

      @be_id = @zz5_work_period.set_multiple_workday_data(id, time_begin, time_end, time_break, date, @user.id)

      # manual call of calculate carries necessary to account for changed worktimes
      @zz5_work_period.calculate_carries
      @zz5_work_period.save_work_period
      @carry = Zz5GeneralUtil.secondsToTime(@zz5_work_period.workdays[0].carry_over)
      Rails.logger.info "save_day, @carry: " + @carry.to_s
      @vacation = @zz5_work_period.get_vacation_entitlement_in_days(date.to_date + 1.days)

      respond_to do |format|
        format.json { render :partial => "workdays/saved_msg" }
      end
    else
      render_403
    end
  end

  def delete_worktime
    @user = User.current

    if @user.allowed_to?(:view_zz5, nil, :global => true)

      begin Zz5BeginEndTimes.find(params[:id])
      be = Zz5BeginEndTimes.find(params[:id])
      be.delete
      rescue ActiveRecord::RecordNotFound

      end

      date = params[:date]
      init_controller(date.to_date, 0)
      @be_id = 0

      respond_to do |format|
        format.json { render :partial => "workdays/saved_msg" }
      end

    else
      render_403
    end
  end

  def save_absence
    @user = User.current

    if @user.allowed_to?(:view_zz5, nil, :global => true)
      date = params[:date]
      absence_type_id = (params[:absence_reason]).to_s
      absence_time = (params[:absence_time]).to_s
      absence_type = get_absence_type(absence_type_id)

      init_controller(date.to_date, 0)
      Rails.logger.info "absence type: " + absence_type.to_s
      Zz5Absence.create_or_update_absence_for_week_day_and_type(@zz5_work_period.workdays[0], absence_type, absence_time)

      @zz5_work_period.calculate_carries
      @zz5_work_period.save_work_period
      @carry = Zz5GeneralUtil.secondsToTime(@zz5_work_period.workdays[0].carry_over)
      @vacation = @zz5_work_period.get_vacation_entitlement_in_days(date.to_date + 1.days)
      respond_to do |format|
        format.json { render :partial => "workdays/saved_msg" }
      end
    else
      render_403
    end
  end

  def save_te
    @user = User.current

    if @user.allowed_to?(:view_zz5, nil, :global => true)

      @te_id = create_or_update_time_entry(params[:data])

      if @te_id == -1
        @te_id = params[:data]["id"]
      end

      respond_to do |format|
        format.json { render :partial => "workdays/saved_msg" }
      end

    else
      render_403
    end

  end

  def delete_te
    @user = User.current

    if @user.allowed_to?(:view_zz5, nil, :global => true)

      begin TimeEntry.find(params[:id])
      te = TimeEntry.find(params[:id])
      @te_id = te.spent_on.wday
      if(@te_id == 0)
        @te_id = 6;
      else
        @te_id = @te_id-1;
      end
      te.delete
      rescue ActiveRecord::RecordNotFound

      end

      respond_to do |format|
        format.json { render :partial => "workdays/saved_msg" }
      end

    else
      render_403
    end
  end

  def pin_issue
    @user = User.current

    if @user.allowed_to?(:view_zz5, nil, :global => true)

      issue_id = params[:data]["issue_id"]
      pin = params[:data]["pinned"]

      if pin
        # add to pinnedtickets table
        pinned_issue = Zz5PinnedTicket.new(:issue_id => issue_id, :user_id => @user.id)
        if pinned_issue.save
          #Rails.logger.info "pinned ticket successfully!"
          Zz5RemovedTicket.where("user_id = ? AND issue_id = ?", @user.id, issue_id).destroy_all
        else
          #Rails.logger.info "failed pinning ticket!"
        end
      else
        # remove from pinnedtickets table
        Zz5PinnedTicket.where("user_id = ? AND issue_id = ?", @user.id, issue_id).destroy_all
      end

      respond_to do |format|
        format.json { render :partial => "workdays/saved_msg" }
      end

    else
      render_403
    end
  end

  def remove_issue
    @user = User.current

    if @user.allowed_to?(:view_zz5, nil, :global => true)

      issue_id = params[:data]["issue_id"]
      remove = params[:data]["remove"]
      removed_issue = Zz5RemovedTicket.new(:issue_id => issue_id, :user_id => @user.id)

      if remove
        if removed_issue.save
          #Rails.logger.info "removed ticket successfully!"
          Zz5PinnedTicket.where("user_id = ? AND issue_id = ?", @user.id, issue_id).destroy_all
        else
          #Rails.logger.info "failed removing ticket!"
        end
      else
        Zz5RemovedTicket.where("user_id = ? AND issue_id = ?", @user.id, issue_id).destroy_all
      end

      respond_to do |format|
        format.json { render :partial => "workdays/saved_msg" }
      end

    else
      render_403
    end
  end

  def load_issue
    @user = User.current

    if @user.allowed_to?(:view_zz5, nil, :global => true)

      @issue_id = params[:data]["issue_id"]
      begin_date = params[:data]["begin_date"].to_date
      end_date = params[:data]["end_date"].to_date

      @issue = load_issue_data(@issue_id, begin_date, end_date)

      respond_to do |format|
        format.json { render :partial => "workdays/load_issue" }
      end

    else
      render_403
    end
  end

  # saves the content of a block entry
  def saveblock
    #Rails.logger.info "WorkdayController, saveblock"

    @user = User.current

    if @user.allowed_to?(:view_zz5, nil, :global => true)
      #Rails.logger.info "user is allowed to save block entries"

      block_date_from = params[:from].to_s
      block_date_to = params[:to].to_s
      absence_type_id = params[:id].to_s

      #Rails.logger.info "+++++ block_date_from: '" + block_date_from + "'"
      #Rails.logger.info "+++++ block_date_to: '" + block_date_to + "'"
      #Rails.logger.info "+++++ absence_type_id: '" + absence_type_id + "'"

      # create work weeks
      first_absence_day = Date.strptime(block_date_from, '%Y-%m-%d')
      last_absence_day = Date.strptime(block_date_to, '%Y-%m-%d')

      #Rails.logger.info "saveblock, first_absence_day:" + first_absence_day.to_s
      #Rails.logger.info "saveblock, last_absence_day:" + last_absence_day.to_s
      work_period = Zz5Workperiod.new(@user, block_date_from, block_date_to)
      #@zz5_work_week.calculate_carries

      work_period.workdays.each do |workday|

        #Rails.logger.info "saveblock, current day: " + current_day.to_s
        #workday = Zz5Workday.where(:user_id => @user.id).where(:date => zz5_work_day.date).first_or_create

        absence_type = nil

        if !workday.date.sunday? && !workday.date.saturday?


          employment = Zz5Employment.where("user_id = ? AND start <= ?", @user.id, workday.date).order(:start).last

          if employment.nil?
            employment = Zz5Employment.where(:user_id => @user.id).order(:start).last
          end

          if workday.date >= employment.start
            workday.target = Time.at(employment.employment / 5).utc.strftime "%H:%M"
            #Rails.logger.info "target for " + workday.date.to_s + " = " + workday.target.to_s
          end


          #workday.target = Time.parse("07:42")
          absence_type = get_absence_type(absence_type_id)
          #Rails.logger.info "saveblock, absence_type: " + absence_type.to_s
        end

        if !absence_type.nil?
          duration = workday.target.strftime "%H:%M"
        else
          duration = nil
        end

        Zz5Absence.create_or_update_absence_for_week_day_and_type(workday, absence_type, duration)

        workday.save
      end

      # create work weeks to save the time differences
      #Rails.logger.info "+++++ first_day_first_workweek: " + first_day_first_workweek.to_s
      #Rails.logger.info "+++++ first_day_last_workweek: " + first_day_last_workweek.to_s
      work_period.calculate_carries
      work_period.save_work_period

      respond_to do |format|
        format.html
        format.js { render inline: "location.reload();" }
      end

    else
      #Rails.logger.info "user is not allowed to save block entries"
      render_403
    end
  end

  # shows the block entry dialog
  def blockentry
    #Rails.logger.info "WorkdayController, blockentry"

    respond_to do |format|
      format.js
    end
  end

  # use this method to initialize all instance variables
  #
  # @year, @week and @user must already be set
  def init_controller(from, to)
    @zz5_work_period = Zz5Workperiod.new(@user, from, to)
    @zz5_calculation_labels = ['zz5_actual_time','zz5_target_time','zz5_time_difference','zz5_vacation']
    @current_week = Date.today.cweek.to_s
    @display_projects = Zz5UserPreference.where(:user_id => @user.id).select('display_projects AS display_projects').first.display_projects

    #Rails.logger.info "DISPLAY PROJECT TREE: " + @display_projects.to_s
    # set week day information
    @first_day_current_week = from.beginning_of_week
    @last_day_previous_week = from.beginning_of_week - 1

    if @weekview
      @first_day_previous_period = from.beginning_of_week - 7
      @first_day_next_period = from.beginning_of_week + 7
    else
      @first_day_previous_period = (from - 1).beginning_of_week
      @first_day_next_period = (from + 1).end_of_week
    end

    @display_worktimes = @user.zz5_user_pref.display_worktimes
  end

  def favorite_issues(limit)
    @favorite_issue = {}

    if @weekview
      unsorted_issue_ids_of_the_period = TimeEntry.select('time_entries.issue_id').where("user_id = ? AND issue_id IS NOT NULL AND tweek = ? AND tyear = ?", @user.id.to_s, @week, @year).order("updated_on DESC").uniq
    else
      unsorted_issue_ids_of_the_period = TimeEntry.select('time_entries.issue_id').where("user_id = ? AND issue_id IS NOT NULL AND spent_on = ?", @user.id.to_s, @curr_date).order("updated_on DESC").uniq
    end

    #Rails.logger.info "favorite_issue,  unsorted_issues_of_the_week.length: " +  unsorted_issue_ids_of_the_period.length.to_s
    no_of_unsorted_most_recent_issues = limit - unsorted_issue_ids_of_the_period.length

    #Rails.logger.info "favorite_issue, no_of_unsorted_most_recent_issues: " + no_of_unsorted_most_recent_issues.to_s

    unsorted_issues_of_the_week = []

    pinned_tickets = Zz5PinnedTicket.select("issue_id").where("user_id = ?", @user.id.to_s)
    pinned_ticket_ids = pinned_tickets.map {|t| t.issue_id}
    pinned_ticket_ids.each do |ptid|
      #Rails.logger.info "favorite_issue, pinned_ticket_id: " + ptid.to_s
      te = TimeEntry.where("issue_id = ?", ptid).first

      if te.nil?
        te = TimeEntry.new(:issue_id => ptid, :updated_on => @curr_date)
      end

      unsorted_issues_of_the_week.push(te)
    end

    week_ids = unsorted_issue_ids_of_the_period.map{|te| te.issue_id}
    week_ids.each do |wid|
      #Rails.logger.info "favorite_issue, week_id: " + wid.to_s
      if pinned_ticket_ids.include?(wid)
        next
      end

      if @weekview
        unsorted_issues_of_the_week.push(TimeEntry.where("user_id = ? AND issue_id = ? AND tweek = ? AND tyear = ?", @user.id.to_s, wid, @week, @year).order("updated_on DESC").first)
      else
        unsorted_issues_of_the_week.push(TimeEntry.where("user_id = ? AND issue_id = ? AND spent_on = ?", @user.id.to_s, wid, @curr_date).order("updated_on DESC").first)
      end
    end

    if no_of_unsorted_most_recent_issues > 0
      if !week_ids.empty?
        unsorted_most_recent_issues = TimeEntry.where("user_id = ? AND spent_on < ? AND issue_id IS NOT NULL AND issue_id NOT IN (?)", @user.id.to_s, @first_day_current_week-1, week_ids).order("spent_on DESC")
      else
        unsorted_most_recent_issues = TimeEntry.where("user_id = ? AND spent_on < ? AND issue_id IS NOT NULL", @user.id.to_s, @first_day_current_week-1).order("spent_on DESC")
      end
      sorted_most_recent_issue_ids = unsorted_most_recent_issues.map{|te| te.issue_id}.uniq
      sorted_most_recent_issue_ids = sorted_most_recent_issue_ids[0..no_of_unsorted_most_recent_issues-1]
      #Rails.logger.info "favorite_issue, sorted_most_recent_issue_ids.length: " + sorted_most_recent_issue_ids.length.to_s

      unsorted_most_recent_issues.clear
      sorted_most_recent_issue_ids.each do |id|
        #Rails.logger.info "favorite_issue, te with id: " + TimeEntry.where("issue_id = ?", id).order("spent_on DESC").first.issue_id.to_s
        unsorted_most_recent_issues.push(TimeEntry.where("issue_id = ?", id).order("spent_on DESC").first)
      end

      # get rid of all dupe elements of favorites and tickets of the week
      unsorted_most_recent_issues.each do |te|
        unsorted_issues_of_the_week.each_with_index do |te2, i|
          if te.issue_id.inspect == te2.issue_id.inspect
            unsorted_issues_of_the_week.delete_at(i)
          end
        end
      end

      #Rails.logger.info "favorite_issues, unsorted_issues_of_the_week: " + unsorted_issues_of_the_week.to_s
      unsorted_issues = unsorted_most_recent_issues + unsorted_issues_of_the_week
    else
      unsorted_issues = unsorted_issues_of_the_week
    end

    sorted_issues = []

    if @user.zz5_user_pref.favorite_ticket_order == Zz5Constants::BY_ISSUE_ID
      #Rails.logger.info "favorite issues, by issue id"
      #Rails.logger.info "favorite_issues, sorted_issues: " + unsorted_issues.to_s
      sorted_issues = unsorted_issues.sort_by{ |obj| obj.issue_id }
    elsif @user.zz5_user_pref.favorite_ticket_order == Zz5Constants::BY_UPDATED_ON
      #Rails.logger.info "favorite issues, by updated on"
      sorted_issues = unsorted_issues.sort_by{ |obj| obj.updated_on }.reverse
    end


    @project_names = {}
    sorted_issues.each do |te|
      #Rails.logger.info "Time entry: " + te.to_s

      pinned = Zz5PinnedTicket.where("user_id = ? AND issue_id = ?", @user, te.issue_id)

      if pinned.empty?
        pinned = false
      else
        pinned = true
      end

      time_entries_per_day = {}
      entries_exist = false

      @zz5_work_period.workdays.each do |work_day|
        a = TimeEntry.select([:id,:hours,:activity_id,:comments]).where(:user_id=>@user,:issue_id =>te.issue_id,:spent_on=>work_day.date).map { |c| [c.id , Zz5GeneralUtil.hoursToTime(c.hours), c.activity_id, c.comments] }
        time_entries_per_day[work_day.date] = a
        if !a.empty?
          entries_exist = true
        end
      end

      removed = Zz5RemovedTicket.where("user_id = ? AND issue_id = ?", @user, te.issue_id)

      if !removed.empty? && !entries_exist
        #sorted_issues.delete(te)
        next
      end

      tracker_name = Tracker.select("t.name").joins("AS t LEFT OUTER JOIN issues AS i ON i.tracker_id = t.id").where("i.id = ?", te.issue_id).first.name

      issue_info = []
      issue_info.push(pinned)
      issue_info.push(tracker_name)
      issue_info.push(time_entries_per_day)

      @favorite_issue[te] = issue_info


      # execute sql query for retrieving up to 3 project names
      # get these names as an array
      # write those names to @project_names hash at [issue_id]
      result = Issue.select("p1.name AS first_name, p2.name AS second_name, p3.name AS third_name").joins("AS i1 LEFT OUTER JOIN projects AS p1 ON p1.id = i1.project_id LEFT OUTER JOIN projects AS p2 ON p2.id = p1.parent_id LEFT OUTER JOIN projects AS p3 ON p3.id = p2.parent_id").where("i1.id = ?", te.issue_id).first

      project_names = Array.new
      project_names.push(result.first_name)
      project_names.push(result.second_name)
      project_names.push(result.third_name)
      project_names.compact!

      @project_names[te.issue_id.to_s] = []
      project_names.reverse_each do |project|
        @project_names[te.issue_id.to_s].push(project)
      end
    end
  end

  def load_issue_data(issue_id, begin_date, end_date)
    time_entries_per_day = {}

    curr_date = begin_date

    while curr_date < end_date + 1.days
      time_entries_per_day[curr_date] = TimeEntry.select([:id,:hours,:activity_id,:comments]).where(:user_id=>@user,:issue_id =>issue_id,:spent_on=>curr_date).map { |c| [c.id , Zz5GeneralUtil.hoursToTime(c.hours), c.activity_id, c.comments] }
      curr_date = curr_date + 1.days
    end

    tracker_name = Tracker.select("t.name").joins("AS t LEFT OUTER JOIN issues AS i ON i.tracker_id = t.id").where("i.id = ?", issue_id).first.name

    issue_info = []
    issue_info.push(tracker_name)
    issue_info.push(time_entries_per_day)

    @issue = issue_info
  end


  def create_dummy_data
    @project_names = {}
    my = {}

    @zz5_work_period.workdays.each do |work_day|
      my[work_day.date] = [0, 0, 0, nil]
    end

    yield

    te = set_up_shit
    @favorite_issue[te] = my
    @project_names[te.issue_id.to_s] = ["DO NOT USE THIS! OTHERWISE PROGRAM WILL CRASH!"]
  end

  #---------------------------------------#
  # functions to get issue specific stuff #
  #---------------------------------------#

  # Returns the users' projects ordered by name
  def user_projects_ordered
    #Rails.logger.info "user_projects_ordered started"
    @projects = @user.projects.sort {|a,b| a.name <=> b.name}
    #find_assigned_issues_by_project(projects.first) if (projects.length == 1)
    #Rails.logger.info "user_projects_ordered left"
  end

  # Find issues assigned to the user and issues not assigned to him which the user has spent time
  def find_assigned_issues_by_project(project)
    @user = User.current
    begin
      @project = Project.find(project)
    rescue
      @assigned_issues = []
    else
      @assigned_issues = Issue.find(:all,
                                    :conditions => ["(#{Issue.table_name}.assigned_to_id=? or #{TimeEntry.table_name}.user_id=?) AND #{IssueStatus.table_name}.is_closed=? AND #{Project.table_name}.status=#{Project::STATUS_ACTIVE} AND #{Project.table_name}.id=?", @user.id, @user.id, false, @project.id],
                                    :include => [ :status, :project, :tracker, :priority, :time_entries ],
                                    :order => "#{Issue.table_name}.id DESC, #{Issue.table_name}.updated_on DESC")
    end
    @assigned_issues
  end


  private

  # used to compute the workperiod end
  # if to = 0 then workperiod only will contain 1 day
  def get_week_period_end(from)

    days = @user.zz5_user_pref.display_days.to_i

    to = 0

    if @weekview
      to = from + days.days - 1.days

      if days == 1
        to = from + 6.days
      end
    end

    return to
  end

  def get_absence_type(absence_type_id)

    absence_type = nil
    if !absence_type_id.nil? && !absence_type_id.blank?
      absence_type = Zz5AbsenceType.find(absence_type_id)
    end

    return absence_type
  end

  def update_time_entry(time_entry)
    Rails.logger.info "------------------- UPDATE TIME ENRTIES ---------------------------------"

    activity_time_entry = time_entry["activity"]
    comment_time_entry = time_entry["comment"]
    time = time_entry["hours"]
    id = time_entry["id"]

    if time == "" || time == "00:00"
      te = TimeEntry.find(id)
      te_id = te.spent_on.wday

      if(te_id == 0)
        te_id = 6;
      else
        te_id = te_id-1;
      end
      te.delete

      return te_id
    end

    #update only valid time strings
    if Zz5GeneralUtil.is_valid_time(time)
      hours = Zz5GeneralUtil.timeToHours(time)
      Rails.logger.info "update_time_entry, update hours: " + hours.to_s
      if hours == 0.0
        TimeEntry.find(id).delete
      else
        te = TimeEntry.find(id)
        if(activity_time_entry != nil)
          if (te.hours - hours != 0.0)
            updated_on = DateTime.now
            te.update_attributes(:hours=>hours,:updated_on =>updated_on, :activity_id => activity_time_entry, :comments => comment_time_entry.to_s)
          elsif (te.activity_id.to_s != activity_time_entry.to_s || te.comments.to_s != comment_time_entry.to_s)
            updated_on = DateTime.now
            te.update_attributes(:updated_on =>updated_on, :activity_id => activity_time_entry, :comments => comment_time_entry.to_s)
          end
        else
          if (te.hours - hours != 0.0)
            updated_on = DateTime.now
            te.update_attributes(:hours=>hours,:updated_on =>updated_on)
          end
        end
      end
    end

    return id
    Rails.logger.info "------------------- UPDATE TIME ENRTIES ---------------------------------"
  end

  def search_for_time_entry(time_entry, value_id, entry_id)
    entry = []
    time_entry.each do |id, value|
      if (entry_id.to_i > -1)
        id = id.split('-')
        if (id[0] == value_id && id[1] == entry_id)
          entry[0] = id[0]
          entry[1] = value

          return entry
        end
      else
        if (id == value_id)
          entry[0] = id
          entry[1] = value

          return entry
        end
      end
    end
  end


  def create_time_entry(time_entry)

    #Rails.logger.info "------------------- Create TIME ENRTIES ---------------------------------"
    activity_time_entry = time_entry["activity"]
    comment_time_entry = time_entry["comment"]
    issue_id = time_entry["issue_id"]
    time = time_entry["hours"]
    date = time_entry["date"]

    #Rails.logger.info "create_time_entry, new_time entry issue id: " + issue_id.to_s
    #Rails.logger.info "create_time_entry, date: " + date.to_s
    valid = Zz5GeneralUtil.is_valid_time(time)

    if !activity_time_entry.nil?

      if activity_time_entry == "-1"
        time_entry_activity = TimeEntryActivity.where("id = 16").first
      else
        time_entry_activity = TimeEntryActivity.where("id = ?", activity_time_entry).first
      end
    end

    hours = Zz5GeneralUtil.timeToHours(time)

    if hours > 0.0
      #Rails.logger.info "create_time_entries, value: " + time.to_f.to_s
      #Rails.logger.info "create_time_entries, valid: " + valid.to_s
      updated_on = DateTime.now
      if valid
        if activity_time_entry != '-1' && !comment_time_entry.nil?
          te=TimeEntry.new(:issue_id => issue_id, :spent_on => date, :hours => time, :updated_on =>updated_on, :created_on =>updated_on, :activity => time_entry_activity, :comments => comment_time_entry)
          te.user = User.current
          if te.save
            Rails.logger.info "create_time_entries, saved time entry WITH activity! " + comment_time_entry.to_s
          else
            Rails.logger.info "create_time_entries, failed to save time entry WITH activity!!! "
          end
        elsif !comment_time_entry.nil?
          te=TimeEntry.new(:issue_id => issue_id, :spent_on => date, :hours => time, :updated_on =>updated_on, :created_on =>updated_on, :activity => TimeEntryActivity.first, :comments => comment_time_entry)
          te.user = User.current
          if te.save
            Rails.logger.info "create_time_entries, saved time entry WITH ccomment!!!! "
          else
            Rails.logger.info "create_time_entries, failed to save time entry WITH ccomment!!! "
          end

          #hacky-wacky: needed to update activity manually because saving will fail if non existing activity is passed to TimeEntry constructor
          id = te.id
          sql = "UPDATE time_entries SET activity_id = -1 WHERE id = " + id.to_s + ";"
          ActiveRecord::Base.connection.execute(sql)
        elsif activity_time_entry != '-1'
          te=TimeEntry.new(:issue_id => issue_id, :spent_on => date, :hours => time, :updated_on =>updated_on, :created_on =>updated_on, :activity => time_entry_activity)
          te.user = User.current
          if te.save
            Rails.logger.info "create_time_entries, saved time entry WITH activity! "
          else
            Rails.logger.info "create_time_entries, failed to save time entry WITH ccomment!!! "
          end
        else
          te=TimeEntry.new(:issue_id => issue_id, :spent_on => date, :hours => time, :updated_on =>updated_on, :created_on =>updated_on, :activity => TimeEntryActivity.first )
          te.user = User.current

          if te.save
            Rails.logger.info "create_time_entries, saved time entry WITHOUT activity! "
          else
            Rails.logger.info "create_time_entries, failed to save time entry WITHOUT activity!!! "
          end

          #hacky-wacky: needed to update activity manually because saving will fail if non existing activity is passed to TimeEntry constructor
          id = te.id
          sql = "UPDATE time_entries SET activity_id = -1 WHERE id = " + id.to_s + ";"
          ActiveRecord::Base.connection.execute(sql)
        end
        return te.id
      end
    end

    return -1
    Rails.logger.info "------------------- Create TIME ENRTIES ---------------------------------"
  end

  def create_or_update_time_entry(time_entry)


    if(time_entry["new"] === true)
      #create new time entry
      id = create_time_entry(time_entry)
    else
      #get existing time entry
      id = update_time_entry(time_entry)
    end

    #also check if something changed or not

    #update attributes accordingly
    #delete time entry if hours == 00:00

    #save te
    return id
  end

  def get_week_day_string(day_int)

    case day_int.to_i
      when 1
        day_string = "monday"
      when 2
        day_string = "tuesday"
      when 3
        day_string = "wednesday"
      when 4
        day_string = "thursday"
      when 5
        day_string = "friday"
      when 6
        day_string = "saturday"
      when 7
        day_string = "sunday"
    end

    return day_string.to_s
  end

  def get_week_day_int(day_str)

    case day_str.to_s
      when "monday"
        day_int = 1
      when "tuesday"
        day_int = 2
      when "wednesday"
        day_int = 3
      when "thursday"
        day_int = 4
      when "friday"
        day_int = 5
      when "saturday"
        day_int = 6
      when "sunday"
        day_int = 7
    end

    return day_int
  end

  def get_next_day_url
    if @day.to_i < 7
      next_day_url = "/zz5/" + @year  + "/" + @week + "/" + (@day.to_i + 1).to_s
    else
      next_day_url = "/zz5/" + @first_day_next_period.cwyear.to_s + "/" + @first_day_next_period.cweek.to_s + "/1"
    end

    return next_day_url
  end

  def get_prev_day_url
    if @day.to_i > 1
      prev_day_url = "/zz5/" + @year  + "/" + @week + "/" + (@day.to_i - 1).to_s
    else
      prev_day_url = "/zz5/" + @first_day_previous_period.cwyear.to_s + "/" + @first_day_previous_period.cweek.to_s + "/7"
    end

    return prev_day_url
  end
end