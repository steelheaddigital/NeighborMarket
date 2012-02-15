class Buyer < ActiveRecord::Base
  has_one :user, :as => :rolable
  validates :delivery_instructions, :presence => true
end
