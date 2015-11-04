module ProjectReportHelper

  include Zz5GeneralHelper
  
  #prints the entire project
  def printTree(project)

    tree = printLines(project, 0, 1)

    return tree["html"].html_safe
  end

  # prints all project lines with their respective issues and subprojects
  def printLines(project, parent_id, level)
    html_code = ""
    #Rails.logger.info "" + project.name.to_s
    html_code += printProjectLine(project, parent_id, level)

    issues = Issue.where(:project_id => project.id)
    estimated_sum = issues.sum(:estimated_hours)

    worked_sum = 0.0

    issues.each do |issue|
      #hours_worked = TimeEntry.find_by_sql(["SELECT COALESCE(SUM(hours), 0) AS sum FROM time_entries WHERE issue_id = ? AND spent_on BETWEEN ? AND ?", issue.id.to_s, @from.to_s, @to.to_s]).first.sum.round(2)
      hours_worked = TimeEntry.where("issue_id = ? AND spent_on BETWEEN ? AND ?", issue.id, @from, @to).sum("hours").round(2)
      if hours_worked != 0 || issue.estimated_hours != 0.0
        html_code += printIssueLines(issue, hours_worked, level+1)
      end
      worked_sum += hours_worked
    end

    difference = estimated_sum - worked_sum

    #Rails.logger.info "project " + project.name.to_s + ": " + project.children.visible.count.to_s

    estimated_temp_sum = 0.0
    worked_temp_sum = 0.0
    difference_temp = 0.0

    Project.find(project.id).children.each do |child|
      subprojects = printLines(child, project.id, level+1)
      estimated_temp_sum += subprojects["estimated"]
      worked_temp_sum += subprojects["worked"]
      difference_temp += subprojects["difference"]
      html_code += subprojects["html"]
    end

    estimated_result = estimated_sum + estimated_temp_sum
    worked_result = worked_sum + worked_temp_sum
    difference_result = difference + difference_temp

    html_code += '<script>'
    html_code += 'estimated_sum["' + project.id.to_s + '"] = "' + Zz5GeneralUtil.hoursToTime(estimated_result).to_s + '";'
    html_code += 'worked_sum["' + project.id.to_s + '"] = "' + Zz5GeneralUtil.hoursToTime(worked_result).to_s + '";'
    html_code += 'difference["' + project.id.to_s + '"] = "' + Zz5GeneralUtil.hoursToTime(difference_result).to_s + '";'
    html_code += '</script>'

    return result = {
      "estimated" => estimated_result,
      "worked" => worked_result,
      "difference" => difference_result,
      "html" => html_code
    }
  end

  def printProjectLine(project, parent_id, level)

    if level == 1 || level == 2
      row_string = "<tr id=" + project.id.to_s + " class=\"project-row\"><td>"
    else
      row_string = "<tr id=" + project.id.to_s + " class=\"project-row\" style=\"display: none;\"><td>"
    end

    level.times {
      row_string += "<div class=\"project-name-col\">"
    }
    
    if parent_id == 0
      row_string += "<label id=\"project_" + project.id.to_s + "\" data-parent-id=\"project_" + parent_id.to_s + "\">- "
    else
      row_string += "<label id=\"project_" + project.id.to_s + "\" data-parent-id=\"project_" + parent_id.to_s + "\">+ "
    end

    row_string += project.name.to_s
    row_string += "</label>"

    level.times {
      row_string += "</div>"
    }
    row_string += "</td>"

    row_string += "<td>"
    row_string += "<div class=\"project-time-col\">"
    row_string += "<label id='estimated_" + project.id.to_s + "' data-project-estimated='" + parent_id.to_s + "'>"
    row_string += "</label>"
    row_string += "</div>"
    row_string += "</td>"

    row_string += "<td>"
    row_string += "<div class=\"project-time-col\">"
    row_string += "<label id='worked_" + project.id.to_s + "' data-project-worked='" + parent_id.to_s + "'>"
    row_string += "</label>"
    row_string += "</div>"
    row_string += "</td>"

    row_string += "<td>"
    row_string += "<div class=\"project-time-col\">"
    row_string += "<label id='diff_" + project.id.to_s + "' data-project-diff='" + parent_id.to_s + "'>"
    row_string += "</label>"
    row_string += "</div>"
    row_string += "</td>"

    row_string += "</tr>"

    return row_string.html_safe
  end

  def printIssueLines(issue, hours_worked, level)

    if level == 2
      row_string = "<tr id=" + issue.id.to_s + " class=\"issue-row\"><td class=\"issue-col\">"
    else
      row_string = "<tr id=" + issue.id.to_s + " class=\"issue-row\" style=\"display: none;\"><td class=\"issue-col\">"
    end

    level.times {
      row_string += "<div class=\"issue-name-col\">"
    }

    row_string += "<label id=\"issue_" + issue.id.to_s + "\" data-parent-id=\"project_" + issue.project_id.to_s + "\" class=\"issue\" title=\"" + issue.subject.to_s + "\">"
    row_string += "#" + issue.id.to_s + " " + issue.subject.to_s
    row_string += "</label>"

    level.times {
      row_string += "</div>"
    }
    row_string += "</td>"

    time_estimated = issue.estimated_hours

    if time_estimated.nil?
      time_estimated = 0.0
    end

    time_estimated = time_estimated.round(2)

    row_string += "<td>"
    row_string += "<div class=\"issue-time-col\">"
    if time_estimated < 0.0
      row_string += "<label data-pid-estimated='" + issue.project_id.to_s + "' class='negative-hours'>"
    else
      row_string += "<label data-pid-estimated='" + issue.project_id.to_s + "'>"
    end
    row_string += Zz5GeneralUtil.hoursToTime(time_estimated).to_s
    row_string += "</label>"
    row_string += "</div>"
    row_string += "</td>"

    row_string += "<td>"
    row_string += "<div class=\"issue-time-col\">"
    if hours_worked < 0.0
      row_string += "<label data-pid-worked='" + issue.project_id.to_s + "' class='negative-hours'>"
    else
      row_string += "<label data-pid-worked='" + issue.project_id.to_s + "'>" 
    end
    row_string += Zz5GeneralUtil.hoursToTime(hours_worked).to_s
    row_string += "</label>"
    row_string += "</div>"
    row_string += "</td>"

    time_difference = time_estimated - hours_worked

    row_string += "<td>"
    row_string += "<div class=\"issue-time-col\">"
    
    if time_difference < 0.0
      row_string += "<label data-pid-diff='" + issue.project_id.to_s + "' class='negative-hours'>"
    else
      row_string += "<label data-pid-diff='" + issue.project_id.to_s + "'>"
    end

    row_string += Zz5GeneralUtil.hoursToTime(time_difference).to_s
    row_string += "</label>"
    row_string += "</div>"
    row_string += "</td>"

    row_string += "</tr>"

    return row_string.html_safe
  end

  def period_options

    return options_for_select([[l(:label_all_time), 'all'],
                               [l(:label_between), 'between'],
                               [l(:label_greater_or_equal), 'greater_or_equal'],
                               [l(:label_less_or_equal), 'less_or_equal']], @selection )
  end

end
