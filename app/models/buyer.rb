class Buyer < ActiveRecord::Base
  has_one :role, :as => :rolable
  validates :delivery_instructions, :presence => true
  attr_accessible :delivery_instructions
end
