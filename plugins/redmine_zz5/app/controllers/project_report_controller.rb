class ProjectReportController < ApplicationController
  unloadable

  def show

    if User.current.allowed_to?(:manage_zz5, nil, :global => true)
      @user = User.current

      @zz5_work_period = Zz5Workperiod.new(@user, Date.today)
      @project = Project.find(params[:pid])
      @free_period = false
      @issue_strlen = 18

      @min_date = (TimeEntry.minimum(:spent_on, :include => :project, :conditions => Project.allowed_to_condition(User.current, :view_time_entries)) || Date.today) - 1
      @max_date = Date.today

      #Rails.logger.info "Report min: " + @min_date.to_s + " max: " + @max_date.to_s
      cond = @project.project_condition(Setting.display_subprojects_issues?)

      if User.current.allowed_to?(:view_time_entries, @project)
        @total_hours = TimeEntry.visible.sum(:hours, :include => :project, :conditions => cond).to_f
      end

      @from = params[:from]
      @to = params[:to]
      @selection = params[:period]

      if @from.nil?|| @from.empty? || @from.blank?
        #Rails.logger.info "Setting parameter '@from' to default value"
        @from = @min_date
      end

      if @to.nil?|| @to.empty? || @to.blank?
        #Rails.logger.info "Setting parameter '@to' to default value"
        @to = @max_date
      end

      #Rails.logger.info "Report between from: " + @from.to_s + " to: " + @to.to_s

      respond_to do |format|
        format.html
      end
    else
      render_403
    end
  end

end
