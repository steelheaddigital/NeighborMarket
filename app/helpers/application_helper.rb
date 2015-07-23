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

module ApplicationHelper
  
  def my_devise_error_messages!
    return "" if resource.errors.empty? && resource.rolable.errors.empty?

    messages = rolable_messages = ""

    if !resource.errors.empty?
      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    end

    if !resource.rolable.errors.empty?
      rolable_messages = resource.rolable.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    end

    messages = messages + rolable_messages   
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count + resource.rolable.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation">
    <h2>#{sentence}</h2>
    <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end
  
  def cache_key_for_categories
    order_cycle = OrderCycle.current_cycle.nil? ? 0 : OrderCycle.current_cycle.id
    top_level_category_count = TopLevelCategory.count
    second_level_category_count = SecondLevelCategory.count
    top_level_category_max_updated_at = TopLevelCategory.maximum(:updated_at).try(:utc).try(:to_s, :number)
    second_level_category_max_updated_at = SecondLevelCategory.maximum(:updated_at).try(:utc).try(:to_s, :number)
    
    "categories/all-#{order_cycle}-#{top_level_category_count}-#{second_level_category_count}-#{top_level_category_max_updated_at}-#{second_level_category_max_updated_at}"
  end
  
  def cache_key_for_categories_sidemenu
    order_cycle = OrderCycle.current_cycle.nil? ? 0 : OrderCycle.current_cycle.id
    top_level_category_count = TopLevelCategory.count
    second_level_category_count = SecondLevelCategory.count
    top_level_category_max_updated_at = TopLevelCategory.maximum(:updated_at).try(:utc).try(:to_s, :number)
    second_level_category_max_updated_at = SecondLevelCategory.maximum(:updated_at).try(:utc).try(:to_s, :number)
    
    "categories_sm/all-#{order_cycle}-#{top_level_category_count}-#{second_level_category_count}-#{top_level_category_max_updated_at}-#{second_level_category_max_updated_at}"
  end
  
  def get_categories
    categories = Array.new
    current_cycle = OrderCycle.current_cycle
    TopLevelCategory.find_each do |category|
      if current_cycle
        top_level_item_count = InventoryItem.joins(:order_cycles)
                                            .where("top_level_category_id = ? AND is_deleted = false AND approved = true AND order_cycles.status = 'current'", category.id)
                                            .count
      else
        top_level_item_count = 0
      end
      second_level_categories = Array.new
      SecondLevelCategory.where(:top_level_category_id => category.id).find_each do |second_level_category|
        if current_cycle
          second_level_count = InventoryItem.joins(:order_cycles)
                                            .where("second_level_category_id = ? AND is_deleted = false AND approved = true AND order_cycles.status = 'current'", second_level_category.id)
                                            .count
        else
          second_level_count = 0
        end
        if second_level_count > 0 || second_level_category.active?
          second_level_categories.push({:id => second_level_category.id, :name => second_level_category.name, :count => second_level_count})
        end
      end
      if top_level_item_count > 0 || category.active?
        categories.push({:name => category.name, :count => top_level_item_count, :second_level => second_level_categories})
      end
    end
    return categories
  end
  
  def item_name(inventory_item)
    if inventory_item.name == nil || inventory_item.name == ""
      inventory_item.second_level_category.name 
    else
      inventory_item.name
    end  
  end
  
  def item_quantity_label(inventory_item, quantity)
    if inventory_item.price_unit != "each"
      if quantity > 1
        return inventory_item.price_unit.singularize.pluralize
      else
        return inventory_item.price_unit.singularize
      end
    end
  end
  
  def price_unit_label(inventory_item)
    if inventory_item.price_unit != "each"
      return "per #{inventory_item.price_unit.singularize}"
    else
      return inventory_item.price_unit.singularize
    end
  end
  
  def order_cycle_message
    cycle = OrderCycle.current_cycle
    site_settings = SiteSetting.instance
    
    if site_settings.delivery_only?
      delivery_method = "delivery"
    elsif site_settings.drop_point_only?
      delivery_method = "pickup"
    else
      delivery_method = "pickup or delivery"
    end
    
    if cycle
      "The current order cycle will end on #{format_date_time(cycle.end_date)}. Place your order now for #{delivery_method} on #{format_date_time(cycle.buyer_pickup_date)}"
    else
      next_cycle = OrderCycle.find_by_status("pending")
      if next_cycle
        "There is no current order cycle open. The next cycle will start on #{format_date_time(next_cycle.start_date)}. Orders for the next cycle are scheduled to be available for #{delivery_method} on #{format_date_time(next_cycle.buyer_pickup_date)}"
      else
        "There is no current order cycle and none scheduled. Please check back later."
      end
    end
  end
  
  def format_date_time(datetime)
    "#{datetime.in_time_zone.strftime("%m/%d/%Y")} at #{datetime.in_time_zone.strftime("%I:%M %p")}"
  end
  
  def format_short_date(datetime)
    "#{datetime.in_time_zone.strftime("%m/%d/%Y")}" if !datetime.nil?
  end
  
  def site_name
    if SiteSetting.instance
      SiteSetting.instance.site_name
    else
      "Neighbor Market"
    end
  end
  
  def nav_item_is_active(*args)
    args.each do |arg|
      if arg.is_a?(Hash)
        return "active" if arg[:action] == params[:action] && arg[:controller] == params[:controller]
      else
        return "active" if arg == params[:action]
      end
    end
  end
  
  def second_level_nav_is_active(pages)
    pages.each do |page|
      if params[:action] == page
        return "secondLevel collapse in"
      else
        return "secondLevel collapse"
      end
    end
  end
  
  def last_search_path
    session[:last_search_path]
  end
  
  def buyer_address(buyer)
    address = ''
    unless buyer.address.nil?
      address = address + buyer.address + ", "
    end
    unless buyer.city.nil?
      address = address + buyer.city + ", "
    end
    unless buyer.state.nil?
      address = address + buyer.state + " "
    end
    unless buyer.zip.nil?
      address = address + buyer.zip
    end

    address
  end
  
  def tooltip_label(label_text, tooltip_text)
    html = %[<label>
      #{label_text}
      <i class="icon-question-sign" data-toggle="tooltip" title="#{tooltip_text}"></i>
    </label>]
    
    html.html_safe
  end
  
  def contains_item_with_minimum_text(type)
    "Your #{type} contains some items that require a minimum amount to be purchased between all buyers for this order cycle before the seller will deliver the items.  The quantity that still needs to be purchased is shown in the \"Minimum\" column below. They are included in your total, but if the minimum is not met before the end of the order cycle these items will be removed from your order and any payments will be refunded.  You can help reach the minimum by #{'sharing this item on Facebook using the "share" button below and' if SiteSetting.instance.facebook_enabled } encouraging your friends and family to also purchase the item."
  end
  
  def pageless(total_pages, url = nil, container = nil)
    opts = {
        :totalPages => total_pages,
        :url        => url,
        :loaderHtml => "<div id=\"pageless-loader\" style=\"text-align: center; width: 100%; display: none;\"><div class=\"msg\" style=\"font-size:2em\">Loading more items...</div><img src=\"#{image_path('ajax-loader.gif')}\" alt=\"loading more results\" style=\"margin:10px auto\"></div>"
    }

    container && opts[:container] ||= container

    javascript_tag("$('#{container}').pageless(#{opts.to_json});")
  end
  
  def facebook
    app_id = SiteSetting.instance.facebook_app_id
    tag = %[$(function() {
    $.getScript('//connect.facebook.net/en_US/sdk.js', function(){
	      FB.init({
	        appId: '#{app_id}',
	      	version: 'v2.0',
			    xfbml: true
	      });
	    });
    })]
    
    javascript_tag(tag)
  end

  def show_user_payment_instructions?(cart_item)
    cart_item.payment_status == 'Due on receipt'
  end
end
