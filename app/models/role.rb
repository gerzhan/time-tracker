class Role < ActiveRecord::Base

	has_many :user

	def self.USER
		Role.find_by_name("USER")
	end

	def self.MANAGER
		Role.find_by_name("MANAGER")
	end

	def self.ADMIN
		Role.find_by_name("ADMIN")
	end

end
