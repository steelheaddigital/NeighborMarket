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
  
  def get_categories
    categories = Array.new
    current_cycle = OrderCycle.current_cycle
    TopLevelCategory.find_each do |category|
      if current_cycle
        top_level_item_count = InventoryItem.joins(:order_cycles)
                                            .where("top_level_category_id = ? AND quantity_available > 0 AND is_deleted = false AND approved = true AND order_cycles.status = 'current'", category.id)
                                            .count
      else
        top_level_item_count = 0
      end
      second_level_categories = Array.new
      SecondLevelCategory.where(:top_level_category_id => category.id).find_each do |second_level_category|
        if current_cycle
          second_level_count = InventoryItem.joins(:order_cycles)
                                            .where("second_level_category_id = ? AND quantity_available > 0 AND is_deleted = false AND approved = true AND order_cycles.status = 'current'", second_level_category.id)
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
    if cycle
      "The current order cycle will end on #{format_date_time(cycle.end_date)}. Place your order now for delivery on #{format_date_time(cycle.buyer_pickup_date)}"
    else
      next_cycle = OrderCycle.find_by_status("pending")
      if next_cycle
        "There is no current order cycle open. The next cycle will start on #{format_date_time(next_cycle.start_date)}. Orders for the next cycle are scheduled to be delivered on #{format_date_time(next_cycle.buyer_pickup_date)}"
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
    if SiteSetting.first
      SiteSetting.first.site_name
    else
      "Neighbor Market"
    end
  end
  
  def nav_item_is_active(page_name)
    "active" if params[:action] == page_name
  end
  
  def last_search_path
    session[:last_search_path]
  end
  
  def buyer_address(buyer)
    address = ""
    if !buyer.address.nil?
      address = address + buyer.address + ", "
    end
    if !buyer.city.nil?
      address = address + buyer.city + ", "
    end
    if !buyer.state.nil?
      address = address + buyer.state + " "
    end
    if !buyer.zip.nil?
      address = address + buyer.zip
    end
  end
  
end
