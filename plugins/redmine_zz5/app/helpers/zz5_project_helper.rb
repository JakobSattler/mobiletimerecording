module Zz5ProjectHelper
	
	def edit_time_entries_allowed(pid)
		
		project = Project.find(pid)
		
		if User.current.allowed_to?(:edit_own_time_entries, project) || User.current.allowed_to?(:edit_time_entries, project)
			return true
		end

		return false
	end

end