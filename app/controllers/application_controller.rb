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

class ApplicationController < ActionController::Base
  include CurrentCart
  
  protect_from_forgery
  helper_method :current_cart
  helper_method :current_order_cycle_pickup_date
  helper_method :current_order_cycle_end_date
  around_filter :set_time_zone
  before_filter :current_order_id
  before_filter :completed_order_id
  before_filter :set_action
  after_filter :add_headers
  
  def after_sign_in_path_for(resource)
    if resource.manager? && current_order_id.nil? && completed_order_id.nil?
      return site_settings_path
    end
    
    if resource.approved_seller? && current_order_id.nil? && completed_order_id.nil?
      return seller_index_path
    end
    
    if resource.buyer? && resource.roles.count == 1
      if current_order_id
        return edit_order_path(current_order_id)
      elsif completed_order_id
        return edit_order_path(completed_order_id)
      else
        return root_path
      end
    end
    
    home_user_home_path(:current_order_id => current_order_id, :completed_order_id => completed_order_id)
    
  end
  
  def set_time_zone(&block)
    timezone = SiteSetting.instance.time_zone if SiteSetting.instance
    Time.use_zone(timezone, &block)
  end
  
  def current_order_id
    if user_signed_in? && current_user.buyer?
      current_order = current_user.orders.find_by_order_cycle_id(OrderCycle.current_cycle_id)
      @current_order_id = current_order.id if current_order
    end
  end
  
  def completed_order_id
    if user_signed_in? && current_user.buyer? && OrderCycle.pending_delivery && !OrderCycle.current_cycle
      completed_order = current_user.orders.joins(:order_cycle).where("order_cycles.buyer_pickup_date >= ? AND order_cycles.status = ?", DateTime.now.utc, "complete").last
      @completed_order_id = completed_order.id if completed_order
    end
  end

  def add_headers
    #For AJAX Requests, add the flash message to custom headers so they can be displayed via JS
    return unless request.xhr?
    response.headers['X-Notice'] = flash[:notice]  unless flash[:notice].blank?
    response.headers['X-Alert'] = flash[:alert]  unless flash[:alert].blank?
  end
  
  def current_ability
    @current_ability ||= Ability.new(current_user, session)
  end
  
  def site_name
    SiteSetting.instance.site_name
  end
  
  def set_action
    url = Rails.application.routes.recognize_path(request.referrer, method: request.method.to_sym)
    session[:previous_action] = {controller: url[:controller], action: url[:action]}
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    logger.error "CanCan Access Denied: #{exception.message}"
    render file: "#{Rails.root}/public/404", formats: [:html], status: 404, layout: false
  end
  
end
