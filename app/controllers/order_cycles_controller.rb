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

class OrderCyclesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @order_cycle_settings = OrderCycleSetting.first ? OrderCycleSetting.first : OrderCycleSetting.new
    @order_cycle_settings.padding ||= 0
    @order_cycle = OrderCycle.get_order_cycle
    
    respond_to do |format|
      format.html
    end
  end

  def update
    @order_cycle_settings = OrderCycleSetting.new_setting(params[:order_cycle_setting])
    @order_cycle_settings.padding ||= 0

    case params[:commit]
    when 'Save and Start New Cycle'
      @order_cycle = OrderCycle.build_initial_cycle(params[:order_cycle], @order_cycle_settings)
    when 'Update Settings'
      @order_cycle = OrderCycle.update_current_order_cycle(params[:order_cycle], @order_cycle_settings)
    end
    
    respond_to do |format|
      if @order_cycle_settings.save && @order_cycle.save_and_set_status
        format.html { redirect_to order_cycles_path, notice: 'Order Cycle Settings Successfully Saved!' }
      else
        format.html { render :index }
      end
    end
  end
end
