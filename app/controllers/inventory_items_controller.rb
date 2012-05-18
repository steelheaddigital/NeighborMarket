class InventoryItemsController < ApplicationController
  load_and_authorize_resource
  
  def new
    @item = InventoryItem.new
    @top_level_categories = TopLevelCategory.all
    @second_level_categories = {}
    
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def create
    @item = InventoryItem.new(params[:inventory_item])
    @top_level_categories = TopLevelCategory.all
    if(@item.top_level_category)
      @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(@item.top_level_category.id)
    else
      @second_level_categories = {}
    end
    
    
    respond_to do |format|
      if @item.save
        format.js { render :nothing => true }
      else
        format.js { render :new, :layout => false }
      end
    end
    
  end
  
  def edit
    @item = InventoryItem.find(params[:id])
    @top_level_categories = TopLevelCategory.all
    @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(@item.top_level_category.id)
    
    respond_to do |format|
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
        format.js { render :nothing => true }
      else
        format.js { render :edit, :layout => false }
      end
    end
  end
  
  def destroy
    inventory = InventoryItem.find(params[:id])
    inventory.destroy

    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
  
  def get_second_level_category
    
    @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(params[:category_id])
    
    render :json => @second_level_categories
        
  end
  
end
