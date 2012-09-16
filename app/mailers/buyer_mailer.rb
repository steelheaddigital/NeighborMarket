class BuyerMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: "admin@steelheaddigital.com"
  
  def order_mail(buyer, order)
    @order = order
    @order_pickup_date = OrderCycle.current_cycle.buyer_pickup_date
    @site_settings = SiteSetting.first
    mail( :to => buyer.email, 
          :subject => "Your order summary from #{@site_settings.site_name}")
  end
  
end
