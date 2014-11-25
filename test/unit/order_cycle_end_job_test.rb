require 'test_helper'

class OrderCycleEndJobTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.deliveries = []
  end  

  test "send emails sends emails" do
    order_cycle = order_cycles(:current)
    job = OrderCycleEndJob.new
    
    job.send_emails(order_cycle)
    deliveries = ActionMailer::Base.deliveries
    
    assert !deliveries.empty?
    assert_equal 8, deliveries.count
  end
  
  test "remove_items_from_orders_where_minimum_not_met sets minimum_reached_at_order_cycle_end to false if minimum not met" do
    order_cycle = order_cycles(:current)
    cart_item = cart_items(:minimum_not_met)
    job = OrderCycleEndJob.new
    
    job.remove_items_from_orders_where_minimum_not_met(order_cycle.id)
    updated_cart_item = CartItem.find(cart_item.id)
    
    assert !updated_cart_item.minimum_reached_at_order_cycle_end
  end
  
  test "perform creates new order cycle and sends emails" do
    OrderCycle.delete_all
    the_date = DateTime.now
    current_cycle = OrderCycle.new(:start_date => the_date,
                               :end_date => the_date,
                               :status => "current",
                               :seller_delivery_date => the_date, 
                               :buyer_pickup_date => the_date)
    current_cycle.save(:validate => false)                     
    job = OrderCycleEndJob.new
    
    job.perform
    deliveries = ActionMailer::Base.deliveries
    new_cycle = OrderCycle.where(:status => "pending").first
    
    assert !deliveries.empty?
    assert_equal 6, deliveries.count
    assert_equal the_date.advance(:days => 1).to_s, new_cycle.start_date.to_datetime.to_s
    assert_equal the_date.advance(:days => 1).to_s, new_cycle.end_date.to_datetime.to_s
    assert_equal the_date.advance(:days => 1).to_s, new_cycle.seller_delivery_date.to_datetime.to_s
    assert_equal the_date.advance(:days => 1).to_s, new_cycle.buyer_pickup_date.to_datetime.to_s
    assert_equal OrderCycle.find(current_cycle.id).status, "complete"
    
  end
  
  test "queue_post_pickup_job queues new post_pickup_job" do
    order_cycle = order_cycles(:current)
    job = OrderCycleEndJob.new
    
    job.queue_post_pickup_job(order_cycle)
    queued_job = Delayed::Job.where("queue = ?","post_pickup")
    
    assert_not_nil queued_job.first
    assert_equal queued_job.first.run_at, order_cycle.buyer_pickup_date + 1.day
  end

end