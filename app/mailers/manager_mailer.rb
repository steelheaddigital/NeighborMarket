class ManagerMailer < BaseMailer
  
  def new_seller_mail(user, manager)
    @user = user
    @site_settings = SiteSetting.first
    mail( :to => manager.email, 
          :subject => "New seller has signed up at #{@site_settings.site_name} - Pending Verification" )
  end
  
  def inventory_approval_required(seller, manager, inventory_item)
    @seller = seller
    @inventory_item = inventory_item
    @site_settings = SiteSetting.first
    
    mail( :to => manager.email,
          :subject => "#{seller.username} at #{@site_settings.site_name} has posted an inventory item that needs approval")
    
  end
  
  def inventory_item_change_request(manager, description, inventory_item)
    @inventory_item = inventory_item
    @description = description
    site_settings = SiteSetting.first
    
    mail( :to => manager.email,
          :subject => "#{@inventory_item.user.username} at #{site_settings.site_name} has requested a change to an inventory item")
  end
  
  def order_change_request(manager, description, order)
    @order = order
    @description = description
    site_settings = SiteSetting.first
    
    mail( :to => manager.email,
          :subject => "#{@order.user.username} at #{site_settings.site_name} has requested a change to an order")
  end
  
end
