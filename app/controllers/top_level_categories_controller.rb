class TopLevelCategoriesController < ApplicationController
  load_and_authorize_resource
  
  def new
    @category = TopLevelCategory.new
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
    
  end

  def create
    @category = TopLevelCategory.new(params[:top_level_category])
    
    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_management_index_path, notice: 'Category successfully updated!'}
        format.js { redirect_to categories_management_index_path }
      else
        format.html { render :new }
        format.js { render :new, :layout => false, :status => 403 }
      end
    end
    
  end
  
  def edit
    @category = TopLevelCategory.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update
  @category = TopLevelCategory.find(params[:id])
  
    respond_to do |format|
      if @category.update_attributes(params[:top_level_category])
        format.html { redirect_to categories_management_index_path, notice: 'Category successfully updated!'}
        format.js { redirect_to categories_management_index_path }
      else
        format.html { render :edit }
        format.js { render :edit, :layout => false, :status => 403 }
      end
    end
    
  end
  
  def destroy
    @category = TopLevelCategory.find(params[:id])
    @category.destroy

    respond_to do |format|
      if @category.destroy
        format.html{ redirect_to categories_management_index_path, notice: 'Category successfully deleted!' }
      else
        format.html{ redirect_to categories_management_index_path, notice: 'Unable to delete the category' }
      end
    end
  end
  
end
