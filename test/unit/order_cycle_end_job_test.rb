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
    assert_equal the_date.advance(:days => 1).utc, new_cycle.start_date
    assert_equal the_date.advance(:days => 1).utc, new_cycle.end_date
    assert_equal the_date.advance(:days => 1).utc, new_cycle.seller_delivery_date
    assert_equal the_date.advance(:days => 1).utc, new_cycle.buyer_pickup_date
    assert_equal OrderCycle.find(current_cycle.id).status, "complete"
    
  end

end