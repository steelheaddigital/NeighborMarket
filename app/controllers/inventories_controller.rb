class InventoriesController < ApplicationController
  load_and_authorize_resource
  
  def new
    @inventory = Inventory.new
    @top_level_categories = TopLevelCategory.all
    @second_level_categories = {}
    
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def create
    @inventory = Inventory.new(params[:inventory])
    @top_level_categories = TopLevelCategory.all
    if(@inventory.top_level_category)
      @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(@inventory.top_level_category.id)
    else
      @second_level_categories = {}
    end
    
    
    respond_to do |format|
      if @inventory.save
        format.js { render :nothing => true }
      else
        format.js { render :new, :layout => false }
      end
    end
    
  end
  
  def edit
    @inventory = Inventory.find(params[:id])
    @top_level_categories = TopLevelCategory.all
    @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(@inventory.top_level_category.id)
    
    respond_to do |format|
      format.html {render :layout => false }
      format.js { render :layout => false }
    end
  end
  
  def update
    @inventory = Inventory.find(params[:id])
    @top_level_categories = TopLevelCategory.all
    if(@inventory.top_level_category)
      @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(@inventory.top_level_category.id)
    else
      @second_level_categories = {}
    end
    
    
    respond_to do |format|
      if @inventory.update_attributes(params[:inventory])
        format.js { render :nothing => true }
      else
        format.js { render :edit, :layout => false }
      end
    end
  end
  
  def destroy
    inventory = Inventory.find(params[:id])
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
