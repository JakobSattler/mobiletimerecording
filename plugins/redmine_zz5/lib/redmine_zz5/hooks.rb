module RedmineTt
    class Hooks < Redmine::Hook::ViewListener

        render_on :view_my_account,
            :partial => 'hooks/redmine_zz5/view_my_account_zz5_user_preferences'

        render_on :view_projects_show_sidebar_bottom,
              :partial => 'hooks/redmine_zz5/view_project_report_sidebar_content'
              
    end
end
