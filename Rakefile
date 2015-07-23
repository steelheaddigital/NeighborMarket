#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/testtask'
require 'rails/test_unit/sub_test_task'

namespace :test do
  Rails::TestTask.new('payment_processors' => 'test:prepare') do |t|
    t.pattern = 'test/payment_processors/**/*_test.rb'
  end

  Rails::TestTask.new('jobs' => 'test:prepare') do |t|
    t.pattern = 'test/jobs/**/*_test.rb'
  end
end

Rake::Task['test'].enhance ['test:payment_processors']
Rake::Task['test'].enhance ['test:jobs']

NeighborMarket::Application.load_tasks
