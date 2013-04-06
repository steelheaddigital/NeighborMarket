class InventoryItemChangeRequest < ActiveRecord::Base
  belongs_to :inventory_item
  belongs_to :user
  attr_accessible :complete, :description
end
