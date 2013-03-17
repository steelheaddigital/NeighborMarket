class InventoryItemOrderCycle < ActiveRecord::Base
  belongs_to :inventory_item
  belongs_to :order_cycle
  
  before_destroy :user_can_delete_from_order_cycle
  
  def user_can_delete_from_order_cycle
    if !inventory_item.can_edit?
      errors.add(:base, "Item cannot be removed from the current order cycle since it is contained in one or more orders. If you need to change this item, please <a href=\"#{Rails.application.routes.url_helpers.change_request_inventory_item_path(:id => self.inventory_item_id)}\">send a request</a> to the site manager.".html_safe)
      return false
    end
  end
  
end