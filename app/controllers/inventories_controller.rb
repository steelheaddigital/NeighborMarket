class InventoriesController < ApplicationController
    
  def new
    @inventory = Inventory.new
    @user_id = current_user.id
    @top_level_taxonomies = TopLevelTaxonomy.all
    
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
end
