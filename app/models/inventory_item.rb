class InventoryItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :top_level_category
  belongs_to :second_level_category
  
  attr_accessible :top_level_category_id, :second_level_category_id, :user_id, :name, :price, :price_unit, :quantity_available, :description
  
  validates :top_level_category_id, 
    :second_level_category_id,
    :price,
    :price_unit,
    :quantity_available,
    :presence => true
  
  validates :price, :numericality => {:greater_than_or_equal_to => 0.01}
  validates :quantity_available, :numericality => {:greater_than_or_equal_to => 1}
end
