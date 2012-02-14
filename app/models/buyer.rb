class Buyer < ActiveRecord::Base
  has_one :user, :as => :rolable, :validate => true
  validates :delivery_instructions, :presence => {:message => "Delivery instructions are required"}
end
