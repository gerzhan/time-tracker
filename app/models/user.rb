class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_many :task
  has_many :time_request
  belongs_to :department
  belongs_to :role
  
end
