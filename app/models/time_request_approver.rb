class TimeRequestApprover < ActiveRecord::Base

	belongs_to :department
	belongs_to :time_request_type
	belongs_to :user

end
