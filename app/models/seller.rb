class Seller < ActiveRecord::Base
  has_one :user, :as => :rolable
  validates :payment_instructions, :presence => {:message => "is required"}
end
