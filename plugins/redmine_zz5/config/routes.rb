# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'zz5_project_report/:pid', :to => 'project_report#show'
get 'zz5', :to => 'workdays#index'
get 'zz5/:year/:week', :to => 'workdays#show'
get 'zz5/:year/:week/:day', :to => 'workdays#show'
get 'zz5/report', :to => 'report#index'
get 'zz5/employment', :to => 'employment#show'
get 'zz5/block_entry', :to => 'workdays#blockentry'
get 'zz5/tickets.json', :to => 'ticket_search#index'

post 'zz5_project_report/:pid', :to => 'project_report#show'
post 'zz5/workdays_save', :to => 'workdays#save'
post 'zz5/saveblock', :to => 'workdays#saveblock'
post 'zz5/report_show', :to => 'report#show'
post 'zz5/zz5projects', :to => 'zz5_project#index'
post 'zz5/employment_load', :to => 'employment#load'
post 'zz5/employment_save', :to => 'employment#save'
post 'zz5/ticket_append', :to => 'ticket_search#load'
post 'zz5/load_data', :to => 'workdays#load_data'
post 'zz5/save_day', :to => 'workdays#save_day'
post 'zz5/save_te', :to => 'workdays#save_te'
post 'zz5/delete_te', :to => 'workdays#delete_te'
post 'zz5/pin_issue', :to => 'workdays#pin_issue'
post 'zz5/remove_issue', :to => 'workdays#remove_issue'
post 'zz5/load_issue', :to => 'workdays#load_issue'

# Unused:
#match 'submissions/bulk_submissions' => 'submissions#bulk_submissions', :as => 'bulk_submissions', :via => :post
#post 'save_zz5_user_preferences', :to => 'blocks#edit_zz5_user_preference'