require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  test "sends new review email after create" do
    user = users(:buyer_user)
    reviewable = inventory_items(:one)
    review = reviewable.reviews.new(rating: 1, review: "test")
    review.user = user

    Sidekiq::Testing.inline! do
      review.save
    end

    assert !ActionMailer::Base.deliveries.empty?
  end
  
end