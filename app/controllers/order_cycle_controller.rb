class OrderCycleController < ApplicationController
  load_and_authorize_resource

  def edit
    @order_cycle_settings = OrderCycleSetting.first ? OrderCycleSetting.first : OrderCycleSetting.new
    @order_cycle_settings.padding ||= 0
    @order_cycle = get_order_cycle
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update
    @order_cycle_settings = OrderCycleSetting.new_setting(params[:order_cycle_setting])
    @order_cycle = OrderCycle.build_initial_cycle(params[:order_cycle], @order_cycle_settings)
      
    respond_to do |format|
      if @order_cycle_settings.save and (params[:commit] == 'Save and Start New Cycle' ? @order_cycle.save : true)
        format.html { redirect_to edit_order_cycle_index_path, notice: 'Order Cycle Settings Successfully Saved!'}
        format.js { render :nothing => true }
      else
        format.html { render "order_cycle" }
        format.js { render :edit, :layout => false, :status => 403 }
      end
    end
  end

  private
  
  def get_order_cycle
    if OrderCycle.find_by_status("current")
      order_cycle = OrderCycle.find_by_status("current")
    elsif 
      OrderCycle.find_by_status("pending")
      order_cycle = OrderCycle.find_by_status("pending")
    else
      order_cycle = OrderCycle.new
    end

    return order_cycle
  end

end