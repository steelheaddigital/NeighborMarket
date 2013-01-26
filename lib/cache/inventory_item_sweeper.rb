class InventoryItemSweeper < ActionController::Caching::Sweeper
  observe InventoryItem
  
  def after_create(inventory_item)
    expire_cache_for(inventory_item)
  end
  
  def after_destroy(inventory_item)
    expire_cache_for(inventory_item)
  end

  def after_paranoid_destroy
    expire_cache_for(inventory_item)
  end
  
  def after_copy_to_new_cycle
    expire_cache_for(inventory_item)
  end

  private 
  
  def expire_cache_for(inventory_item)
    expire_fragment('browse_categories_dropdown')
  end

end