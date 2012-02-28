class Buyer < ActiveRecord::Base
  has_one :role, :as => :rolable
  validates :delivery_instructions, :presence => true
  attr_accessible :delivery_instructions, :buyer_attributes
  accepts_nested_attributes_for :role
end
