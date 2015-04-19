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

class SecondLevelCategoriesController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  load_and_authorize_resource
  
  def show
    @inventory_items = InventoryItem.joins(:order_cycles)
                       .where("second_level_category_id = ? AND is_deleted = false AND approved = true AND order_cycles.status = 'current'", params[:id])
                       .order('created_at DESC')
                   
    session[:last_search_path] = request.fullpath          
    respond_to do |format|
      format.html { render 'inventory_items/search', layout: 'layouts/navigational'  }
    end
  end

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
        flash[:notice] = 'Category successfully updated!'
        format.html { redirect_to categories_management_index_path }
        format.js { redirect_to categories_management_index_path }
      else
        format.html { render :new }
        format.js { render :new, :layout => false, :status => 403 }
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
    @category = SecondLevelCategory.find(params[:id])
    
    respond_to do |format|
      if @category.deactivate
        format.html{ redirect_to categories_management_index_path, notice: 'Category successfully deleted!' }
      else
        format.html{ redirect_to categories_management_index_path, notice: 'Unable to delete the category' }
      end
    end

  end
  
end
