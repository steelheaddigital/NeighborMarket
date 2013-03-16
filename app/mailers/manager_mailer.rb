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
  
end
