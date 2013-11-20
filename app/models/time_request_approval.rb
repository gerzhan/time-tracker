class TimeRequestApproval < ActiveRecord::Base

	belongs_to :user
	belongs_to :time_request

end
