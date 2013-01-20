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
  
  def get_top_level_categories
    
    #Get the distinct second level categories
    ids = SecondLevelCategory.select(:top_level_category_id).group(:id, :top_level_category_id)
    
    #Add the top level category id to a new array for each distinct second level category
    id_array = Array.new
    ids.each do |category|
      id_array.push(category.top_level_category_id)
    end
    
    #return only the top level categories that have associated second level categories
    return TopLevelCategory.find(id_array)
    
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
    "#{datetime.strftime("%m/%d/%Y")} at #{datetime.strftime("%I:%M %p")}"
  end
  
  def format_short_date(datetime)
    "#{datetime.strftime("%m/%d/%Y")}" if !datetime.nil?
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
  
end
