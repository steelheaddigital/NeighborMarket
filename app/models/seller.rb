class Seller < ActiveRecord::Base
  has_many :roles, :as => :rolable
  validates :payment_instructions, :presence => true
end
