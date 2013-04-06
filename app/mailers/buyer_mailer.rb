class BuyerMailer < BaseMailer
  
  def order_mail(buyer, order)
    @order = order
    @order_pickup_date = OrderCycle.current_cycle.buyer_pickup_date
    @site_settings = SiteSetting.first
    mail( :to => buyer.email, 
          :subject => "Your order summary from #{@site_settings.site_name}")
  end
  
  def order_modified_mail(seller, order)
    @order = order
    @site_settings = SiteSetting.first
    
    mail( :to => @order.user.email,
          :subject => "Your order at #{@site_settings.site_name} has been modified")
  end
  
  def change_request_complete_mail(change_request)
    @request = change_request
    
    mail( :to => change_request.user.email,
          :subject => "Your order change request has been completed")
  end
  
end
