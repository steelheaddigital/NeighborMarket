class SellerMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: "admin@steelheaddigital.com"

  def seller_approved_mail(user)
    @site_settings = SiteSetting.first
    mail(:to => user.email, :subject => "Your #{@site_settings.site_name} Seller Account Is Approved" )
  end
  
  def new_purchase_mail(seller, order)
    @buyer = order.user
    @cart_items = order.cart_items.joins(:inventory_item).where("inventory_items.user_id = ?", seller.id)
    site_settings = SiteSetting.first
    mail( :to => seller.email, 
          :subject => "A purchase of your product has been made at #{site_settings.site_name}")
  end
end
