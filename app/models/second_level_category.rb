class SecondLevelCategory < ActiveRecord::Base
  belongs_to :top_level_category
  has_one :inventory_item, :dependent => :destroy
  
  attr_accessible :name, :description, :top_level_category_id
  
  validates :name, :presence => true
end
