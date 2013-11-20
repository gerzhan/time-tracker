class Department < ActiveRecord::Base

  has_many :user
  has_many :time_request_approver

  def manager 
  	self.manager_id ? User.find(self.manager_id) : nil
  end

  def manager=(u)
  	if u != nil
  		self.manager_id = u.id
  	end
  end

end
