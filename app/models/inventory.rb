class Inventory < ActiveRecord::Base
  belongs_to :user
  belongs_to :top_level_taxonomy
  belongs_to :second_level_taxonomy
  
  validates :top_level_taxonomy_id, 
    :second_level_taxonomy_id,
    :price,
    :quantity_available,
    :presence => true
end
