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

class InventoryItemsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :search, :browse_all]
  load_and_authorize_resource
  require 'will_paginate/array'
  
  def show
    @inventory_item = InventoryItem.find(params[:id])
    @site_settings = SiteSetting.instance
    
    respond_to do |format|
      format.html { render layout: 'layouts/navigational' }
    end
  end
  
  def new
    @item = InventoryItem.new
    @top_level_categories = TopLevelCategory.where(:active => true)
    @second_level_categories = {}
    @inventory_guidelines = SiteContent.instance.inventory_guidelines
    
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
    @inventory_guidelines = SiteContent.instance.inventory_guidelines
    
    if(@item.top_level_category)
      @second_level_categories = SecondLevelCategory.where(:top_level_category_id => @item.top_level_category.id, :active => true)
    else
      @second_level_categories = {}
    end
    
    respond_to do |format|
      if @item.save
        if user.listing_approval_style == "auto"
          flash[:notice] = "Inventory item successfully created!"
        else
          flash[:notice] = "Inventory item successfully created. However, the item must be approved by the site manager before it will be visible to buyers."
          managers = User.joins(:roles).where('roles.name = ?', "manager")
          managers.each do |manager|
            ManagerMailer.delay.inventory_approval_required(user, manager, @item)
          end
        end
        format.html { redirect_to seller_index_path }
        format.js { redirect_to seller_index_path }
      else
        format.html { render :new }
        format.js { render :new, :layout => false, :status => 403 }
      end
    end
    
  end
  
  def edit
    @item = InventoryItem.find(params[:id])
    @top_level_categories = TopLevelCategory.all
    @second_level_categories = SecondLevelCategory.where(:top_level_category_id => @item.top_level_category.id, :active => true)
    @inventory_guidelines = SiteContent.instance.inventory_guidelines
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update
    @item = InventoryItem.find(params[:id])
    @item.current_user = current_user
    @top_level_categories = TopLevelCategory.all
    @inventory_guidelines = SiteContent.instance.inventory_guidelines
    
    if(@item.top_level_category)
      @second_level_categories = SecondLevelCategory.where(:top_level_category_id => @item.top_level_category.id, :active => true)
    else
      @second_level_categories = {}
    end
    
    respond_to do |format|
      if @item.update_attributes(params[:inventory_item])
        flash[:notice] = 'Inventory item successfully updated!'
        format.html { redirect_to :back }
        format.js { redirect_to :back }
      else
        format.html { render :edit }
        format.js { render :edit, :layout => false, :status => 403 }
      end
    end
  end
  
  def destroy
    @inventory = InventoryItem.find(params[:id])
    @inventory.current_user = current_user
    
    respond_to do |format|
      if @inventory.paranoid_destroy
        format.html{ redirect_to :back, notice: "Inventory item successfully deleted!" }
      else
        format.html{ redirect_to :back, notice: 'Unable to delete the item' }
      end
    end
  end
  
  def delete_from_current_inventory
    inventory_item = InventoryItem.find(params[:id])
    inventory_item.current_user = current_user
    order_cycle = OrderCycle.active_cycle
    relation = order_cycle.inventory_item_order_cycles.where(inventory_item_id: params[:id]).first
    
    respond_to do |format|
      if relation.destroy
        format.html{ redirect_to :back, notice: "Inventory item successfully deleted from the current order cycle!" }
      else
        format.html{ redirect_to :back, notice: relation.errors.full_messages.first }
      end
    end
  end
  
  def get_second_level_category
    @second_level_categories = SecondLevelCategory.where(:top_level_category_id => params[:category_id], :active => true)
    
    render :json => @second_level_categories
  end
  
  def search
    @inventory_items = InventoryItem.search(params[:keywords]).order('created_at')

    session[:last_search_path] = request.fullpath
    respond_to do |format|
      format.html { render layout: 'layouts/navigational' }
    end
  end
  
  def browse_all
    @inventory_items = InventoryItem.joins(:order_cycles)
                                    .where("is_deleted = false AND approved = true AND order_cycles.status = 'current'")
                                    .order("created_at DESC")
    
    session[:last_search_path] = request.fullpath
    respond_to do |format|
      format.html { render :search, layout: 'layouts/navigational' }
    end
  end
  
  def units
    units = PriceUnit.select(:name).order(:name).map(&:name)
    
    render :json => units
  end
  
  def user_reviews
    @inventory_items = InventoryItem.select("inventory_items.*, reviews.id AS review_id, reviews.rating AS rating, reviews.review AS review, order_cycles.buyer_pickup_date AS sale_date")
                                    .joins(:cart_items => { :order => :order_cycle })
                                    .joins("LEFT JOIN reviews ON reviews.reviewable_id = inventory_items.id AND reviews.reviewable_type = 'InventoryItem'")
                                    .where("orders.user_id = ? AND order_cycles.status = 'complete'", current_user.id)
                                    .order("order_cycles.buyer_pickup_date DESC")
                                    .uniq

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
end
