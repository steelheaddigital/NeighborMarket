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
    
      if(inventory_item.name == nil || inventory_item.name == "")
        inventory_item.second_level_category.name 
      else
        inventory_item.name
      end  
    
  end 
end
