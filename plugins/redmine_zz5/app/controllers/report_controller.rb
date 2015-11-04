class ReportController < ApplicationController
  unloadable


  # redirect user to current month selection
  def index
    #Rails.logger.info "ReportController, index"

    employment = Zz5Employment.where(:user_id => User.current.id).order(:start).first

    if User.current.allowed_to?(:view_zz5, nil, :global => true) && !employment.nil?
      @users = Array.new
      User.find(:all, :order => "lastname, firstname").each do |u|
        if u.allowed_to?(:view_zz5, nil, :global => true)
          @users.push(u)
        end
      end

      @user_id = User.current.id
      @report_start_date = Date.civil(Date.today.year, Date.today.month, 1)
      @report_end_date = Date.civil(Date.today.year, Date.today.month, -1)

      check_report_start_date(employment)
      check_report_end_date
      @zz5_work_period = Zz5Workperiod.new(User.current, @report_start_date, @report_end_date)
      render "show"
    else
      render_403
    end
  end


  # show the time report for the selected time period
  def show
    #Rails.logger.info "ReportController, show"

    employment = Zz5Employment.where(:user_id => User.current.id).order(:start).first

    if User.current.allowed_to?(:view_zz5, nil, :global => true) && !employment.nil?
      @users = Array.new
      User.find(:all, :order => "lastname, firstname").each do |u|
        if u.allowed_to?(:view_zz5, nil, :global => true)
          @users.push(u)
        end
      end

      @user_id = (params[:user_select].nil?) ? User.current.id : params[:user_select]["user_id"]
      @report_start_date = Date.strptime(params[:start_date], "%Y-%m-%d")
      @report_end_date = Date.strptime(params[:end_date], "%Y-%m-%d")
      check_report_start_date(employment)
      check_report_end_date
      Rails.logger.info "report end date: " + @report_end_date.to_s
      @zz5_work_period = Zz5Workperiod.new(User.find(@user_id), @report_start_date, @report_end_date)
    else
      render_403
    end
  end

  def check_report_start_date(employment)
    #Rails.logger.info "check_report_start_date called..."

    employment_start_date = employment.start

    if @report_start_date < employment_start_date
      #Rails.logger.info "check_report_start_date adjust report start date..."
      @report_start_date = employment_start_date
      return 0
    end
  end

  def check_report_end_date
    #Rails.logger.info "check_report_start_date called..."
    last_workday_date = Zz5Workday.where(:user_id => @user_id).order(:date).last.date - 1

    if @report_end_date > last_workday_date
      #Rails.logger.info "check_report_start_date adjust report start date..."
      @report_end_date = last_workday_date
    end
  end

end
