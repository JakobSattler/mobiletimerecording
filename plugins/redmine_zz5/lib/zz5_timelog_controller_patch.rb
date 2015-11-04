require_dependency 'timelog_controller'

module Zz5TimelogControllerPatch

  def self.included(base) # :nodoc:

    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      alias_method_chain :new, :custom_parameters
    end
  end

  module InstanceMethods

    def new_with_custom_parameters
      Rails.logger.info "called custom_with_new instead of new!"

      begin
        Rails.logger.info "create time entry for day: " + params[:spent_on].to_s
        @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => params[:spent_on], :activity => TimeEntryActivity.first)
        @time_entry.safe_attributes = params[:time_entry]
      rescue => e
        Rails.logger.info "rescue: for day: " + User.current.today
        new_without_custom_parameters
      end


      Rails.logger.info "custom_with_new finished"
    end
  end

end

TimelogController.send(:include, Zz5TimelogControllerPatch)
