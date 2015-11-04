class Zz5ProjectController < ApplicationController
  unloadable

  def index
    @user = User.current
    @year = params[:year]
    @ww = params[:ww]
    @pid = params[:pid]


    #check user permissions
    if User.current.allowed_to?(:view_zz5, nil, :global => true)

      from = Date.commercial(@year.to_i, @ww.to_i, 1)
      days = @user.zz5_user_pref.display_days.to_i
      to = 0
      if @weekview
        to = from + days.days - 1.days
      end
      @zz5_work_period = Zz5Workperiod.new(@user, from, to)

      begin
        project = Project.find(@pid.to_s)
      rescue => e
        logger.error "Unable to find project: #{e}"
        render_403
      end
      Rails.logger.info "project id: " + @pid.to_s + project.to_s
      @projects = project.children

      if User.current.allowed_to?(:edit_own_time_entries, project) || User.current.allowed_to?(:edit_time_entries, project) || User.current.allowed_to?(:log_time, project)
        Rails.logger.info "User: " + User.current.to_s + " is allowed_to: edit_own_time_entries or edit_time_entries!"
        curr_date = Date.commercial(@year.to_i, @ww.to_i, 1)
        @issues = Issue.where("project_id = ? AND ((status_id != 3 AND status_id != 5 AND status_id != 6 AND status_id != 8) OR closed_on >= ? AND created_on <= ?)", @pid, curr_date, curr_date).order('issues.id ASC')
        @time_entries = Zz5WorkweekTimeEntry.new(@year, @ww, @user, @pid, true)
      else
        Rails.logger.info "User: " + User.current.to_s + " is NOT allowed_to: edit_own_time_entries or edit_time_entries!"
        #create dummy entries to render empty json response
        @issues = []
        @time_entries = Zz5WorkweekTimeEntry.new(@year, @ww, @user, @pid, false)
      end

      respond_to do |format|
        format.json {render :partial => "workdays/project_table_entry", :locals => {:parent_id => @pid.to_i}}
      end

    else
      render_403
    end

  end



end
