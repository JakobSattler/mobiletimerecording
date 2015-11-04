class TicketSearchController < ApplicationController
	unloadable


	def index
		@user = User.current
		projects = Project.where(Project.visible_condition(@user)).map{|p| p.id}
		Rails.logger.info "projects: " + projects.to_s
		Rails.logger.info "params: " + params[:q].to_s



		@tickets = Issue.visible.where("project_id in (?) AND UPPER(subject) LIKE UPPER(?)", projects, "%#{params[:q]}%")

		begin
			@tickets.push(Issue.where("project_id in (?)", projects).find(params[:q]))
		rescue ActiveRecord::RecordNotFound
			Rails.logger.info "TicketSearchController, no record found - whatevs man"
		end

		@tickets.each do |t|
			Rails.logger.info "TicketSearchController, result ticket: " + t.subject.to_s
		end

		respond_to do |format|
			format.html
			format.json { render :partial => "ticket_search/tickets" }
		end
	end

	def load
		@ticket_ids = params[:_json]

		Rails.logger.info "ticket ids: " +  @ticket_ids.to_s
	end

end
