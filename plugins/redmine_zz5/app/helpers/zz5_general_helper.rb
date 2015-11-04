module Zz5GeneralHelper

  def calendar_for(field_id, minDate, maxDate, initialDate=nil)
    
    Rails.logger.info "calendar_for, field_id. " + field_id.to_s + ", minDate: " + minDate.to_s + "maxDate:" + maxDate.to_s
    include_calendar_headers_tags(minDate, maxDate)

    appendSetDate = false

    unless initialDate.nil?
      partsDefault = initialDate.to_s.split('-')
      partsDefault[1] = (partsDefault[1].to_i).to_s
      appendSetDate = true
    end

    datepickerInit = "$(function() { $('##{field_id}').datepicker(datepickerOptions); "

    if appendSetDate
      datepickerInit += "$('##{field_id}').datepicker('setDate', new Date(#{partsDefault[0]},#{partsDefault[1]},#{partsDefault[2]}));"
    end

    datepickerInit += "});"

    javascript_tag(datepickerInit)
  end

  # can be passed strings and dates alike
  def include_calendar_headers_tags(minDate, maxDate)
    unless @calendar_headers_tags_included
      @calendar_headers_tags_included = true
      content_for :header_tags do
        start_of_week = Setting.start_of_week
        start_of_week = l(:general_first_day_of_week, :default => '1') if start_of_week.blank?
        # Redmine uses 1..7 (monday..sunday) in settings and locales
        # JQuery uses 0..6 (sunday..saturday), 7 needs to be changed to 0
        start_of_week = start_of_week.to_i % 7
        partsMin = minDate.to_s.split('-')
        partsMax = maxDate.to_s.split('-')

        Rails.logger.info "include_calendar_headers_tags, partsMin: " + partsMin.to_s
        Rails.logger.info "include_calendar_headers_tags, partsMax: " + partsMax.to_s

        tags = javascript_tag(
          "var datepickerOptions={dateFormat: 'yy-mm-dd', firstDay: #{start_of_week}, " +
          "minDate: new Date(#{partsMin[0]},#{(partsMin[1].to_i - 1)},#{partsMin[2]}), " +
          "maxDate: new Date(#{partsMax[0]},#{(partsMax[1].to_i - 1)},#{partsMax[2]}), " +
          "showOn: 'button', buttonImageOnly: true, buttonImage: '/plugin_assets/redmine_zz5/images/calendar.png', showButtonPanel: true, showWeek: true, showOtherMonths: true, selectOtherMonths: true};")
        jquery_locale = l('jquery.locale', :default => current_language.to_s)
        unless jquery_locale == 'en'
          tags << javascript_include_tag("i18n/jquery.ui.datepicker-#{jquery_locale}.js")
        end
        tags
      end
    end
  end

  # converts the given seconds to a human-readable "H:M" format where hours can be more than 24 hours
  def convert_seconds_to_hours_and_minutes(seconds)
    seconds_abs = seconds.abs
    minutes = (seconds_abs / 60) % 60
    hours = seconds_abs / (60 * 60)
    return format(((seconds < 0) ? "-" : "") + "%02d:%02d", hours, minutes)
  end

  # converts the given date-time object to seconds from midnight (ie. the date part is ignored)
  def convert_date_time_to_seconds(date_time)
    if date_time.nil?
      return 0.0
    else
      return date_time.hour * 3600 + date_time.min * 60 + date_time.sec
    end
  end

end
