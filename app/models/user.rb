class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_many :task
  has_many :time_request
  has_many :time_request_approval
  has_many :time_request_approver
  belongs_to :department
  belongs_to :role
  
end
