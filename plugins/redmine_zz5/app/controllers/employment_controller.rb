class EmploymentController < ApplicationController
  unloadable

  def show
    if User.current.admin?
      @users = Array.new
      User.find(:all, :order => "lastname, firstname").each do |u|
        if u.allowed_to?(:view_zz5, nil, :global => true)
          @users.push(u)
        end
      end

      respond_to do |format|
        format.html
      end
    else
      render_403
    end
  end

  def save
    if User.current.admin?

      Rails.logger.info "saving employments for user: " + params[:_json][0]['user_id']

      @user_id = params[:_json][0]['user_id']

      handle_employments(params[:_json])

      @employments = Zz5Employment.where(:user_id => @user_id)

      respond_to do |format|
        format.json {render :partial => "employment/employment_table"}
      end
    else
      render_403
    end
  end

  def load
    Rails.logger.info "user id received from ajax request: " + params[:uid].to_s

    @user_id = params[:uid].to_i

    @employments = Zz5Employment.where(:user_id => @user_id)

    respond_to do |format|
      format.json {render :partial => "employment/employment_table"}
    end

  end

  private

  # handles the three different cases (create, update, delete) for each employment
  # create: create a new employment in the DB if its employment_id == 0
  # update: update an employment if its id exists in the db and its delete flag is not set (delete_me == 0)
  # delete: delete an employment if its id exists in the db and its delete flag is set (delete_me != 0)
  def handle_employments(employments)

    Rails.logger.info "taking care of employments"

    employments.each do |employment|
      Rails.logger.info "employment id = " + employment['id']

      if employment['id'].to_i < 0
        create_employment(employment)
      elsif Zz5Employment.where(:id => employment['id'].to_i).exists?

        if employment['delete_me'].to_i == 0
          update_employment(employment)
        elsif employment['delete_me'].to_i == 1
          delete_employment(employment)
        else
          Rails.logger.info "handle_employments: this should not happen!"
        end
      else
        Rails.logger.info "handle_employments: this should not happen!"
      end
    end
  end

  def create_employment(employment)
    Rails.logger.info "create_employment with infos: " + employment.to_s

    employment_record = Zz5Employment.new(:user_id => employment['user_id'])

    if Zz5GeneralUtil.isValidDate(employment['start'])
      employment_record.start = Zz5GeneralUtil.stringToDate(employment['start'])
    else
      employment_record.start = Zz5GeneralUtil.stringToDate("0000-00-00")
    end

    if Zz5GeneralUtil.isValidEmployment(employment['employment'])
      employment_record.employment = Zz5GeneralUtil.timeToSeconds(employment['employment'])
    else
      employment_record.employment = 0
    end

    if Zz5GeneralUtil.isValidVacation(employment['vacation'])
      employment_record.vacation_entitlement = Zz5GeneralUtil.workdaysToSeconds(employment['vacation'], employment_record.employment)
    else
      employment_record.vacation_entitlement = 0;
    end

    if Zz5GeneralUtil.isValidTimeCarry(employment['time_carry'])
      employment_record.time_carry = Zz5GeneralUtil.timeToSeconds(employment['time_carry'])
    else
      employment_record.time_carry = 0
    end

    if Zz5GeneralUtil.isValidOvertime(employment['overtime'])
      employment_record.overtime_allowance = Zz5GeneralUtil.timeToSeconds(employment['overtime'])
    else
      employment_record.overtime_allowance = 0
    end

    if employment['all_in'] == "false"
      employment_record.is_all_in = 0
    else
      employment_record.is_all_in = 1
    end
    employment_record.save

    # if there's another employment with a later date update all workdays & time differences until that employment's start date
    # else update until the most recent time difference
    next_employment = Zz5Employment.where("user_id = ? AND start > ?", @user_id, employment_record.start).order(:start).limit(1).first
    until_date = "9999-12-31".to_date

    if !next_employment.nil?
      until_date = next_employment.start
    end

    target_time = Time.at(employment_record.employment / 5).utc.strftime "%H:%M"
    Rails.logger.info "target time: " + target_time.to_s + " user id: " + employment_record.user_id.to_s + " date: " + employment_record.start.to_s

    if employment_record.employment == 0 && employment_record.vacation_entitlement == 0 &&
        employment_record.time_carry = 0 && employment_record.overtime_allowance == 0
      # don't create workdays! this employment only serves as a measure to compute the correct automatic vacation entitlement
      Rails.logger.info "dummy employment created!"
    else
      update_workdays(employment_record.start, until_date)
    end

  end

  def update_employment(employment)
    Rails.logger.info "updating an employment with infos: " + employment.to_s

    employment_record = Zz5Employment.find(employment['id'].to_i)

    Rails.logger.info "employment_record_id: " + employment_record.id.to_s

    if employment_record.start - Zz5GeneralUtil.stringToDate(employment['start']) == 0 &&
        employment_record.employment - Zz5GeneralUtil.timeToSeconds(employment['employment']) == 0 &&
        employment_record.vacation_entitlement - Zz5GeneralUtil.workdaysToSeconds(employment['vacation'], employment_record.employment) == 0 &&
        employment_record.time_carry - Zz5GeneralUtil.timeToSeconds(employment['time_carry']) == 0 &&
        employment_record.overtime_allowance - Zz5GeneralUtil.timeToSeconds(employment['overtime']) == 0 &&
        employment_record.is_all_in.to_s == employment['all_in'] then

      Rails.logger.info "nothing to update for employment " + employment_record.id.to_s
      return
    end

    if Zz5GeneralUtil.isValidDate(employment['start'])
      employment_record.start = Zz5GeneralUtil.stringToDate(employment['start'])
    end

    if Zz5GeneralUtil.isValidEmployment(employment['employment'])
      employment_record.employment = Zz5GeneralUtil.timeToSeconds(employment['employment'])
    end

    if Zz5GeneralUtil.isValidVacation(employment['vacation'])
      employment_record.vacation_entitlement = Zz5GeneralUtil.workdaysToSeconds(employment['vacation'], employment_record.employment)
    end

    if Zz5GeneralUtil.isValidTimeCarry(employment['time_carry'])
      employment_record.time_carry = Zz5GeneralUtil.timeToSeconds(employment['time_carry'])
    end

    if Zz5GeneralUtil.isValidOvertime(employment['overtime'])
      employment_record.overtime_allowance = Zz5GeneralUtil.timeToSeconds(employment['overtime'])
    end

    if employment['all_in'] == "false"
      employment_record.is_all_in = 0
    else
      employment_record.is_all_in = 1
    end
    employment_record.save

    # if there's another employment with a later date update all workdays & time differences until that employment's start date
    # else update until the most recent time difference
    next_employment = Zz5Employment.where("user_id = ? AND start > ?", @user_id, employment_record.start).order(:start).limit(1).first
    until_date = "9999-12-31".to_date

    if !next_employment.nil?
      until_date = next_employment.start
    end

    update_workdays(employment_record.start, until_date)
  end

  def delete_employment(employment)
    Rails.logger.info "deleting an employment with infos: " + employment.to_s

    employment_record = Zz5Employment.find(employment['id'].to_i)
    start_date = employment_record.start
    next_employment = Zz5Employment.where("user_id = ? AND start > ?", @user_id, employment_record.start).order(:start).limit(1).first
    prev_employment = Zz5Employment.where("user_id = ? AND start < ?", @user_id, employment_record.start).order(:start).limit(1).last

    Zz5Employment.find(employment['id']).delete

    # if there are no other employments there's no need to update anything
    if next_employment.nil? && prev_employment.nil?
      return
    end

    until_date = "9999-12-31".to_date
    # if there's another employment with a later date update all workdays & time differences until that employment's start date
    if !next_employment.nil?
      until_date = next_employment.start
    end

    update_workdays(start_date, until_date)
  end

  def update_workdays(start_date, until_date)

    last_saved_workday = Zz5Workday.where("user_id = ? AND date <= ?", @user_id, until_date).order(:date).last

    # if there are no time differences, there's no need to update anything
    if last_saved_workday.nil?
      return
    end

    @user = User.find(@user_id)

    Rails.logger.info "start: " + start_date.to_s + " last date to update: " + last_saved_workday.date.beginning_of_week.to_s

    workperiod = Zz5Workperiod.new(@user, start_date, last_saved_workday.date)
    #Rails.logger.info "fill_possible_gaps, no first saved week was found!" + workweek.to_s
    Zz5Absence.update_absence_for_work_period(workperiod)
    workperiod.save_work_period
      #Rails.logger.info "fill_possible_gaps, no first saved week was found!" + monday.to_s
  end
end
