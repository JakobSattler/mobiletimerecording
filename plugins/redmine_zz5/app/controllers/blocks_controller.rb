class BlocksController < ApplicationController
  unloadable

  def edit_zz5_user_preference
    #Rails.logger.info "edit_zz5_user_preference, started"

    @user = User.current

    if User.current.allowed_to?(:view_zz5, nil, :global => true)
      #Rails.logger.info "user is allowed to view edit_zz5_user_preference"

      default_work_start = (params[:user][:default_begin]).to_s
      default_work_end = (params[:user][:default_end]).to_s
      default_break_duration = (params[:user][:default_break]).to_s

      #Rails.logger.info "default work_start: " + default_work_start
      #Rails.logger.info "default work_end  : " + default_work_end
      #Rails.logger.info "default break_duration: " + default_break_duration

      @user.zz5_user_pref.work_start = default_work_start
      @user.zz5_user_pref.end_work = default_work_end
      @user.zz5_user_pref.break_duration = default_break_duration

      @user.zz5_user_pref.save

      redirect_to home_url
    else
      #Rails.logger.info "user is not allowed to view edit_zz5_user_preference"
      render_403
    end

    #Rails.logger.info "edit_zz5_user_preference, finished"
  end

end
