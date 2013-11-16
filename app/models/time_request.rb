class TimeRequest < ActiveRecord::Base

	belongs_to :time_request_type
	belongs_to :user

end
