class Buyer < ActiveRecord::Base
  has_many :roles, :as => :rolable
  validates :delivery_instructions, :presence => true
end
