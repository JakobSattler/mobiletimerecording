class Zz5PinnedTicket < ActiveRecord::Base

  attr_accessible :id, :user_id, :issue_id
  belongs_to :time_entries

end