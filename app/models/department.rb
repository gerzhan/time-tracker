class Department < ActiveRecord::Base

  has_one :user, :as => :manager
  has_many :user

end
