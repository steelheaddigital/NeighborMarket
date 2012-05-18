class TopLevelCategoriesController < ApplicationController
  load_and_authorize_resource
  
  def new
    @category = TopLevelCategory.new
    
    respond_to do |format|
      format.js { render :layout => false }
    end
    
  end

  def create
    @category = TopLevelCategory.new(params[:top_level_category])
    
    respond_to do |format|
      if @category.save
        format.js { render :nothing => true }
      else
        format.js { render :new, :layout => false }
      end
    end
    
  end
  
  def edit
    @category = TopLevelCategory.find(params[:id])
    
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def update
  @category = TopLevelCategory.find(params[:id])
  
    respond_to do |format|
      if @category.update_attributes(params[:top_level_category])
        format.js { render :nothing => true }
      else
        format.js { render :edit, :layout => false }
      end
    end
    
  end
  
  def destroy
    @category = TopLevelCategory.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  def new_second_level_category
    @top_level_category = TopLevelCategory.find(params[:id])
    @category = @top_level_category.second_level_categories.build
    
    respond_to do |format|
      format.js { render :layout => false }
    end
    
  end
  
  def create_second_level_category
    @top_level_category = TopLevelCategory.find(params[:id])
    @category = @top_level_category.second_level_categories.build(params[:second_level_category])
    
    respond_to do |format|
      if @top_level_category.save
        format.js { render :nothing => true }
      else
        format.js { render :new, :layout => false }
      end
    end
  end
  
end
