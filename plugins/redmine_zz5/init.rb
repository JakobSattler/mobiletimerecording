require 'redmine'

require 'zz5_user_model_patch'
require_dependency 'redmine_zz5/hooks'
#require_dependency 'backlogs_my_controller_patch'
require_dependency 'zz5_my_controller_patch'
require_dependency 'zz5_timelog_controller_patch'

Redmine::Plugin.register :redmine_zz5 do

  name 'Redmine Zz5 plugin'
  author 'Thorsten Lusser, David Sauperl, Florian Schitter, Bianca Sulzbacher'
  description 'This is a time management plugin for redmine'
  version '0.5.2'
  requires_redmine :version_or_higher => '2.3.1'
  url 'http://www.apus.co.at/path/to/plugin'
  author_url 'http:/www.apus.co.at/about'

  # zz5 configuration settings
  settings :default => {'empty' => true}, :partial => 'settings/redmine_zz5_settings'


  # permissions of zz5
  project_module :zz5_module do
    permission :view_zz5, :zz5 => :index
    permission :manage_zz5, :zz5 => :index
  end

  menu(:top_menu,
       :zz5_menu,
       {:controller => "workdays", :action => 'index'},
       :caption => :zz5_title,
       :if => Proc.new{ User.current.allowed_to?(:view_zz5, nil, :global => true)})

end
