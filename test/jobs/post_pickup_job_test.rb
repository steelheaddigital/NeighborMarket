require 'test_helper'

class PostPickupJobTest < ActiveSupport::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
  end  

  test "perform sends emails" do
    order_cycle = order_cycles(:current)
    site_setting = site_settings(:one)
    site_setting.update_attribute("reputation_enabled", true)
    job = PostPickupJob.new
    
    
    job.perform(order_cycle.id)
    deliveries = ActionMailer::Base.deliveries
    
    assert !deliveries.empty?
    assert_equal 2, deliveries.count
  end
  
end