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
    if inventory_item.price_unit == "lb."
      if quantity > 1
        return "lbs."
      else
        return "lb."
      end
    end
  end
  
  def order_cycle_message
    cycle = OrderCycle.current_cycle
    if cycle
      "<div class=\"alert orderCycleAlert\">
      The current order cycle will end on #{cycle.end_date.strftime("%m/%d/%Y")} at #{cycle.end_date.strftime("%I:%M %p")}. Place your order now for delivery on #{cycle.buyer_pickup_date.strftime("%m/%d/%Y")} at #{cycle.buyer_pickup_date.strftime("%I:%M %p")}
      </div>".html_safe
    else
      next_cycle = OrderCycle.find_by_status("pending")
      if next_cycle
        "<div class=\"alert orderCycleAlert\">
        There is no current order cycle open. The next cycle will start on #{next_cycle.start_date.strftime("%m/%d/%Y")} at #{next_cycle.start_date.strftime("%I:%M %p")}. Orders for the next cycle are scheduled to be delivered on #{next_cycle.buyer_pickup_date.strftime("%m/%d/%Y")} at #{next_cycle.buyer_pickup_date.strftime("%I:%M %p")}
        </div>".html_safe
      else
        "<div class=\"alert orderCycleAlert\">
        There is no current order cycle and none scheduled. Please check back later.
        </div>".html_safe
      end
    end
  end
  
  def current_order_cycle_end_date

  end
  
end
