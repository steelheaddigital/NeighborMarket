class InventoriesController < ApplicationController
    
  def new
    @inventory = Inventory.new
    @user_id = current_user.id
    @top_level_categories = TopLevelCategory.all
    @second_level_categories = {}
    
    respond_to do |format|
      format.html {render}
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
        format.html { render :new }
        format.js { render :new, :layout => false }
      end
    end
    
  end
  
  def get_second_level_category
    
    @second_level_categories = SecondLevelCategory.find_all_by_top_level_category_id(params[:id])
    
    render :json => @second_level_categories
        
  end
  
end
