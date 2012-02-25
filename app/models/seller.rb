class Seller < ActiveRecord::Base
  has_one :role, :as => :rolable
  validates :payment_instructions, :presence => true
  attr_accessible :payment_instructions
end
