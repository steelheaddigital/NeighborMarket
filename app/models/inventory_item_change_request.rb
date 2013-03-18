class InventoryItemChangeRequest < ActiveRecord::Base
  belongs_to :inventory_item
  attr_accessible :complete, :description
end
