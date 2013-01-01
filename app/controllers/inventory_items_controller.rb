class InventoryItemsController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:search, :browse, :browse_all]
  require 'will_paginate/array'
  include CrowdMap
  
  def new
    @item = InventoryItem.new
    @top_level_categories = TopLevelCategory.all
    @second_level_categories = {}
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def create
    user = current_user
    @item = user.inventory_items.new(params[:inventory_item])
    @item.approved = false if user.listing_approval_style == 'manual'
    @top_level_categories = TopLevelCategory.all
    
    if(@item.top_level_category)
      @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(@item.top_level_category.id)
    else
      @second_level_categories = {}
    end
    
    respond_to do |format|
      if @item.save
        if params["crowdmap"]
          CrowdMap.post_item_to_crowdmap(@item)
        end
        format.html { redirect_to seller_index_path, notice: 'Inventory item successfully created!'}
        format.js { render :nothing => true }
      else
        format.html { render "new" }
        format.js { render :new, :layout => false, :status => 403 }
      end
    end
    
  end
  
  def edit
    @item = InventoryItem.find(params[:id])
    @top_level_categories = TopLevelCategory.all
    @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(@item.top_level_category.id)
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update
    @item = InventoryItem.find(params[:id])
    @top_level_categories = TopLevelCategory.all
    
    if(@item.top_level_category)
      @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(@item.top_level_category.id)
    else
      @second_level_categories = {}
    end
    
    respond_to do |format|
      if @item.update_attributes(params[:inventory_item])
        format.html { redirect_to seller_index_path, notice: 'Inventory item successfully updated!'}
        format.js { render :nothing => true }
      else
        format.html { render "edit" }
        format.js { render :edit, :layout => false, :status => 403 }
      end
    end
  end
  
  def destroy
    @inventory = InventoryItem.find(params[:id])
    
    respond_to do |format|
      if @inventory.paranoid_destroy
        format.html{ redirect_to seller_index_path, notice: "Inventory item successfully deleted!" }
        format.js { render :nothing => true }
      else
        format.html{ redirect_to seller_index_path, notice: 'Unable to delete the item' }
        format.js { render :nothing => true, :status => 403 }
      end
    end
  end
  
  def get_second_level_category
    
    @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(params[:category_id])
    
    render :json => @second_level_categories
        
  end
  
  def search
    @inventory_items = InventoryItem.search(params[:keywords])
                                    .sort!{|a,b| b.created_at <=> a.created_at}
                                    .paginate(:page => params[:page], :per_page => 5)

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def browse
    @inventory_items = InventoryItem.joins(:order_cycle)
                                    .where("second_level_category_id = ? AND quantity_available > 0 AND is_deleted = false AND approved = true AND order_cycles.status = 'current'", params[:second_level_category_id])
                                    .order("created_at DESC")
                                    .paginate(:page => params[:page], :per_page => 5)
                                    
    respond_to do |format|
      format.html { render :search }
      format.js { render :search, :layout => false }
    end
  end
  
  def browse_all
    @inventory_items = InventoryItem.joins(:order_cycle)
                                    .where("quantity_available > 0 AND is_deleted = false AND approved = true AND order_cycles.status = 'current'")
                                    .order("created_at DESC").paginate(:page => params[:page], :per_page => 5)
    
    respond_to do |format|
      format.html { render :search }
      format.js { render :search, :layout => false }
    end
  end
  
end
