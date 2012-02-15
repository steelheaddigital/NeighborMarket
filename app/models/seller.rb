class Seller < ActiveRecord::Base
  has_one :user, :as => :rolable
  validates :payment_instructions, :presence => true
  attr_accessible :approved
end
