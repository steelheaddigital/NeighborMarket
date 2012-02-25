class Manager < ActiveRecord::Base
  has_one :role, :as => :rolable
end
