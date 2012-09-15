class SellerMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: "admin@steelheaddigital.com"

  def seller_approved_mail(user)
    mail(:to => user.email, :subject => "Your Neighbor Market Seller Account Is Approved" )
  end
  
  def new_purchase_mail(seller, order)
    @buyer = order.user
    @cart_items = order.cart_items.joins(:inventory_item).where("inventory_items.user_id = ?", seller.id)
    mail( :to => seller.email, 
          :subject => "A purchase of your product has been made at Neighbor Market")
  end
end
