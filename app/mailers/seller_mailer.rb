class SellerMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: "admin@steelheaddigital.com"

  def seller_approved_mail(user)
    mail(:to => user.email, :subject => "Your Neighbor Market Seller Account Is Approved" )
  end
  
  def new_purchase_mail(seller, buyer, cart_items)
    @buyer = buyer
    @cart_items = cart_items
    mail( :to => seller.email, 
          :subject => "A purchase of your product has been made at Neighbor Market")
  end
  
end
