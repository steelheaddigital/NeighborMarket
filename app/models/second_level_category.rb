class SecondLevelCategory < ActiveRecord::Base
  belongs_to :top_level_category
  has_one :inventory_item
  
  attr_accessible :name, :description
  
  validates :name, :presence => true
end
