class TimeRequestType < ActiveRecord::Base

	has_many :time_request

	def self.PTO
		TimeRequestType.find_by_name("PTO")
	end

	def self.OUT_OF_OFFICE
		TimeRequestType.find_by_name("OUT_OF_OFFICE")
	end

end
