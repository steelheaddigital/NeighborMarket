class InventoryItemChangeRequestController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def new
    @item = InventoryItem.find(params[:inventory_item_id])
    @request = InventoryItemChangeRequest.new
    
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @item = InventoryItem.find(params[:inventory_item_id])
    @request = InventoryItemChangeRequest.new(params[:inventory_item_change_request])
    @request.inventory_item = @item
    
    respond_to do |format|
      if @request.save
        managers = User.joins(:roles).where('roles.name = ?', "manager")
        managers.each do |manager|
          ManagerMailer.delay.inventory_item_change_request(manager, @request.description, @item)
        end
        format.html { redirect_to seller_index_path, notice: "Change request successfully sent."}
      else
        format.html { render :new }
      end
    end    
  end
  
end