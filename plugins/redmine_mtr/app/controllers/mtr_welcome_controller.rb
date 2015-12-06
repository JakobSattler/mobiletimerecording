class MtrWelcomeController < ApplicationController
  caches_action :robots

  def mtr_index
    @news = News.latest User.current
    @projects = Project.latest User.current
  end

  def robots
    @projects = Project.all_public.active
    render :layout => false, :content_type => 'text/plain'
  end
end