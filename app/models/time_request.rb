class TimeRequest < ActiveRecord::Base

	belongs_to :time_request_type
	belongs_to :user
	has_many :time_request_approval

end
