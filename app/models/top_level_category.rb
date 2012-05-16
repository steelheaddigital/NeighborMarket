class TopLevelCategory < ActiveRecord::Base
  has_many :second_level_categories, :dependent => :destroy 
  has_one :inventory_item
  
  attr_accessible :name, :description
  
  validates :name, :presence => true
end