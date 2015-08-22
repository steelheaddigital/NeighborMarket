require 'test_helper'
Sidekiq::Testing.fake!

class OrderCycleStartJobTest < ActiveSupport::TestCase
  def setup
    ActionMailer::Base.deliveries = []
    OrderCycleEndJob.jobs.clear
    ReccomendationMailJob.jobs.clear
  end

  test 'sets pending cycle to current' do
    pending_cycle = order_cycles(:not_current)
    job = OrderCycleStartJob.new

    assert_equal 0, OrderCycleEndJob.jobs.size
    job.perform
    assert_equal 1, OrderCycleEndJob.jobs.size
    assert_equal('current', OrderCycle.find(pending_cycle.id).status)
  end

  test 'queues jobs' do
    job = OrderCycleStartJob.new

    assert_equal 0, OrderCycleEndJob.jobs.size
    assert_equal 0, ReccomendationMailJob.jobs.size
    job.perform
    assert_equal 1, OrderCycleEndJob.jobs.size
    assert_equal 1, ReccomendationMailJob.jobs.size
  end
end
