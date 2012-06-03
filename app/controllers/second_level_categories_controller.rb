class SecondLevelCategoriesController < ApplicationController
  load_and_authorize_resource
  
  def new
    @top_level_category = TopLevelCategory.find(params[:id])
    @category = @top_level_category.second_level_categories.build
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
    
  end

  def create
    @top_level_category = TopLevelCategory.find(params[:second_level_category][:top_level_category_id])
    @category = @top_level_category.second_level_categories.build(params[:second_level_category])
    
    respond_to do |format|
      if @top_level_category.save
        format.html { redirect_to management_categories_path, notice: 'Category successfully updated!'}
        format.js { render :nothing => true }
      else
        format.html { render "new" }
        format.js { render :new, :layout => false }
      end
    end
    
  end
  
  def edit
    @category = SecondLevelCategory.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update
  @category = SecondLevelCategory.find(params[:id])
  
    respond_to do |format|
      if @category.update_attributes(params[:second_level_category])
        format.html { redirect_to management_categories_path, notice: 'Category successfully updated!'}
        format.js { render :nothing => true }
      else
        format.html { render "edit" }
        format.js { render :edit, :layout => false }
      end
    end
  end
    
  def destroy
    @category = SecondLevelCategory.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html{ redirect_to management_categories_path, notice: 'Category successfully deleted!' }
      format.js { render :nothing => true }
    end
  end
  
end
