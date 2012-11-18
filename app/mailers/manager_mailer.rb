class ManagerMailer < BaseMailer
  
  def new_seller_mail(user, manager)
    @user = user
    @site_settings = SiteSetting.first
    mail( :to => manager.email, 
          :subject => "New seller has signed up at #{@site_settings.site_name} - Pending Verification" )
  end
  
  def seller_modified_order_mail(seller, manager, order)
    @order = order
    @seller = seller
    @site_settings = SiteSetting.first
    
    mail( :to => manager.email,
          :subject => "An order at #{@site_settings.site_name} has been modified by a seller")
  end
  
end
