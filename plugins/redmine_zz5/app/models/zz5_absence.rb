class Zz5Absence < ActiveRecord::Base

  attr_accessible :id, :duration
  belongs_to :zz5_workday
  belongs_to :zz5_absence_type

  # retrieves or creates an absence object for the given work day
  # ==== Attributes
  #
  # * +workday+ - The workday object the absence belongs to
  def self.create_or_update_absence_for_week_day_and_type(workday, absence_type, duration)
    Rails.logger.info "create_or_update_absence_for_week_day_and_type started"

    # do not create an absence on week ends or holidays
    if Zz5GeneralUtil.is_holiday(workday.date) > 0

      absence = Zz5Absence.where(:zz5_workday_id => workday.id).first_or_create

      next_employment = Zz5Employment.where("user_id = ? AND start > ?", workday.user_id, workday.date).order(:start).limit(1).first
      until_date = Zz5Workday.where("user_id = ? AND date >= ?", workday.user_id, workday.date).last

      if !until_date.nil?
        until_date = until_date.date
      else
        until_date = 0
      end

      unless next_employment.nil?
        until_date = next_employment.start - 1
      end

      #Rails.logger.info "create_or_update_absence_for_week_day_and_type, workday_date: " + workday.date.to_s
      #Rails.logger.info "create_or_update_absence_for_week_day_and_type, duration: " + duration.to_s
      #Rails.logger.info "create_or_update_absence_for_week_day_and_type, absence_type: " + absence_type.to_s

      if absence_type == ""
        absence_type = nil
      end

      if !absence_type.nil?
        Rails.logger.info "create_or_update_absence_for_week_day_and_type, absence_t  ype.id: " + absence_type.id.to_s
      end
      #Rails.logger.info "create_or_update_absence_for_week_day_an d_type, absence.duration: " + absence.duration.to_s

      if !absence_type.nil? && !duration.nil? && duration != ""

        # absence.duration (=old value) is used to be able to calculate the update difference
        if absence.duration.nil?
          absence.duration = "00:00"
        end

        old_duration = absence.duration.strftime "%H:%M"
        update_absence = Zz5GeneralUtil.timeToSeconds(duration) - Zz5GeneralUtil.timeToSeconds(old_duration)
        Rails.logger.info "create_or_update_absence_for_week_day_and_type, update_absence: " + update_absence.to_s

        # save absence type
        if absence_type.id == Zz5Constants::COMPENSATORY_TIME
          workday.absences = 0
        else
          #Zz5Workday.update_all(['carry_forward = carry_forward + ?', update_absence], ['user_id = ? AND date >= ? AND date <= ?', workday.user_id, workday.date.end_of_week + 1, until_date])
          #Zz5Workday.update_all(['carry_over = carry_over + ?', update_absence], ['user_id = ? AND date >= ? AND date <= ?', workday.user_id, workday.date.end_of_week + 1, until_date])
          workday.absences = Zz5GeneralUtil.timeToSeconds(duration)
        end

        absence.duration = duration
        absence.zz5_absence_type = absence_type
        absence.save
      else
        # delete absence type
        #Rails.logger.info "create_or_update_absence_for_week_day_and_type, delete duration: " + Zz5GeneralUtil.timeToSeconds(absence.duration.strftime "%H:%M").to_s

        #Zz5Workday.update_all(['carry_forward = carry_forward - ?', Zz5GeneralUtil.timeToSeconds(absence.duration.strftime "%H:%M")], ['user_id = ? AND date >= ? AND date <= ?', workday.user_id, workday.date.end_of_week + 1, until_date])
        #Zz5Workday.update_all(['carry_over = carry_over - ?', Zz5GeneralUtil.timeToSeconds(absence.duration.strftime "%H:%M")], ['user_id = ? AND date >= ? AND date <= ?', workday.user_id, workday.date.end_of_week + 1, until_date])

        workday.absences = Zz5GeneralUtil.timeToSeconds(duration)
        absence.delete
      end
    end

    Rails.logger.info "create_absence_for_week_day_and_type finished"
  end

  def self.update_absence_for_work_period(workperiod)
    Rails.logger.info "update_absence_for_work_week started for workweek: " + workperiod.to_s

    workperiod.workdays.each do |wdate|
      Zz5Absence.update_absence_for_weekday(wdate)
    end

    Rails.logger.info "update_absence_for_work_week finished"
  end


  private

  def self.update_absence_for_weekday(workday)
    Rails.logger.info "update_absence_for_weekday started"

    # do not create an absence on week ends or holidays
    if Zz5GeneralUtil.is_holiday(workday.date) > 0

      absence = Zz5Absence.where(:zz5_workday_id => workday.id).first

      if !absence.nil?
        # save absence type
        Rails.logger.info "update_absence_for_weekday " + workday.date.to_s + ", udpated absence: " + workday.absences.to_s
        #Zz5Workday.update_all(['absences = ?', Zz5GeneralUtil.timeToSeconds(duration.strftime "%H:%M")], ['id = ?', workday.id])
        absence.duration = Zz5GeneralUtil.secondsToTime(workday.absences)
        absence.save
      end

      Rails.logger.info "update_absence_for_weekday finished"
    end
  end
end
