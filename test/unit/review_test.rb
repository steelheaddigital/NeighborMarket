require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
    Delayed::Worker.delay_jobs = false
  end
  
  def teardown
    Delayed::Worker.delay_jobs = true
  end
  
  test "sends new review email after create" do
    user = users(:buyer_user)
    reviewable = inventory_items(:one)
    review = reviewable.reviews.new(rating: 1, review: "test")
    review.user = user

    review.save

    assert !ActionMailer::Base.deliveries.empty?
  end
  
end