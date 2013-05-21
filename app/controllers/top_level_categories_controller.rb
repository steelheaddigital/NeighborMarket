#
#Copyright 2013 Neighbor Market
#
#This file is part of Neighbor Market.
#
#Neighbor Market is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Neighbor Market is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
#

class TopLevelCategoriesController < ApplicationController
  before_filter :authenticate_user!
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
        flash[:notice] =  'Category successfully created!'
        format.html { redirect_to categories_management_index_path }
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
        flash[:notice] = 'Category successfully updated!'
        format.html { redirect_to categories_management_index_path }
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
