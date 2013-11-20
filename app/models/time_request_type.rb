class TimeRequestType < ActiveRecord::Base

	has_many :time_request
	has_many :time_request_approver

end
