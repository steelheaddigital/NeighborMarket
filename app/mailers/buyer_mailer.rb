class Buyer_Mailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: "admin@steelheaddigital.com"
  
  def order_mail(buyer, order)
    @order = order
    mail( :to => buyer.email, 
          :subject => "Your order summary from the Neighbor Market")
  end
  
end
