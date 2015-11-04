class RenameDisplayWorktimesColumn < ActiveRecord::Migration
    def up
        rename_column :zz5_user_preferences, :display_workdays, :display_worktimes
    end
end