class OrderChangeRequestController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def new
    @order = Order.find(params[:order_id])
    @request = current_user.order_change_requests.build
    
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @order = Order.find(params[:order_id])
    @request = current_user.order_change_requests.build(params[:order_change_request])
    @request.order = @order
    
    respond_to do |format|
      if @request.save
        managers = User.joins(:roles).where('roles.name = ?', "manager")
        managers.each do |manager|
          ManagerMailer.delay.order_change_request(manager, @request.description, @order)
        end
        format.html { redirect_to edit_order_path(:id => @order.id), notice: "Change request successfully sent."}
      else
        format.html { render :new }
      end
    end    
  end
  
  def complete
    request = OrderChangeRequest.find(params[:id])
    request.complete = true
    
    respond_to do |format|
      if request.save
        BuyerMailer.delay.change_request_complete_mail(request)
        format.html { redirect_to order_change_requests_management_index_path, notice: "Request successfully completed."}
      else
        format.html { redirect_to order_change_requests_management_index_path, notice: "Request could not be completed."}
      end
    end
  end
  
end