class OrderCycleEndJob
  include Sidekiq::Worker
  sidekiq_options :queue => :order_cycle_end
  
  def perform
    current_cycle = OrderCycle.find_by_status("current")
    current_cycle_settings = OrderCycleSetting.first
    if current_cycle_settings.recurring
      padding_interval = current_cycle_settings.padding_interval.to_sym
      interval = current_cycle_settings.interval.pluralize.to_sym
      
      new_start_date = current_cycle.end_date.advance(padding_interval => current_cycle_settings.padding)
      new_end_date = current_cycle.end_date.advance(interval => 1)
      new_seller_delivery_date = current_cycle.seller_delivery_date.advance(interval => 1)
      new_buyer_pickup_date = current_cycle.buyer_pickup_date.advance(interval => 1)
      
      new_cycle = OrderCycle.new(:start_date => new_start_date,
                                 :end_date => new_end_date,
                                 :status => "pending",
                                 :seller_delivery_date => new_seller_delivery_date, 
                                 :buyer_pickup_date => new_buyer_pickup_date)
                                 
      if new_cycle.save
        OrderCycle.queue_order_cycle_start_job(new_start_date)
        send_emails(current_cycle)
      end
    else
      current_cycle.status = "complete"
      current_cycle.save
    end
  end
  
  def send_emails(order_cycle)
    sellers = User.joins(:roles).where(:roles => {:name => 'seller'})
    sellers.each do |seller|
      SellerMailer.order_cycle_end_mail(seller, order_cycle).deliver
    end
  end
  
end
