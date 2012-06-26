module InventoryItemsHelper
  
  def item_name(inventory_item)
    
      if(inventory_item.name == nil || inventory_item.name == "")
        inventory_item.second_level_category.name 
      else
        inventory_item.name
      end  
    
  end  
end