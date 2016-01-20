require_dependency 'my_controller'

module Zz5
  module MyControllerPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        after_filter :save_zz5_user_preferences, :only => [:account]
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def save_zz5_user_preferences

        Rails.logger.info "save_zz5_user_preferences started"
        if request.post? && flash[:notice] == l(:notice_account_updated)
          # handle backlog color
          #color = (params[:backlogs] ? params[:backlogs][:task_color] : '').to_s
          #if color == '' || color.match(/^#[A-Fa-f0-9]{6}$/)
           # User.current.backlogs_preference[:task_color] = color
         # else
          #  flash[:notice] = "Invalid task color code #{color}"
         # end

          # handle number of favorites
          no_of_favorites = params[:zz5][:favorite_tickets]

          if no_of_favorites != ''
            User.current.zz5_user_preference.favorite_tickets = no_of_favorites
          end

          # handle display of days
          display_days = params[:zz5][:display_days]

          if display_days != ''
            User.current.zz5_user_preference[:display_days] = display_days
          end

          # handle display of project tree
          display_projects = params[:zz5][:display_projects]

          if display_projects == '1'
            User.current.zz5_user_preference[:display_projects] = true
          else
            User.current.zz5_user_preference[:display_projects] = false
          end

          # handle ticket order
          favorite_ticket_order = params[:zz5][:favorite_ticket_order]
          if favorite_ticket_order != ''
            User.current.zz5_user_preference[:favorite_ticket_order] = favorite_ticket_order
          end

          # handle display worktimes
          display_worktimes =  params[:zz5][:display_worktimes]
          if display_worktimes != ''
            User.current.zz5_user_preference[:display_worktimes] = display_worktimes
          end

          # handle alternative worktimes
          alt_worktimes = params[:zz5][:alternative_worktimes]
          if alt_worktimes == '1'
            User.current.zz5_user_preference[:alternative_worktimes] = true
          else
            User.current.zz5_user_preference[:alternative_worktimes] = false
          end

          # save active record
          User.current.zz5_user_preference.save

        end

        Rails.logger.info "save_zz5_user_preferences finished"

      end
    end

  end
end

MyController.send(:include, Zz5::MyControllerPatch) unless MyController.included_modules.include? Zz5::MyControllerPatch
