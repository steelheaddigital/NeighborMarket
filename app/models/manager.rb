class Manager < ActiveRecord::Base
  has_many :roles, :as => :rolable
end
