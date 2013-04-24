source 'http://rubygems.org'
ruby "1.9.3"

gem 'rails', '3.2.12'
gem 'pg'
gem 'unicorn'

group :development, :test do
  gem 'debugger'
end

group :test do
  # Pretty printed test output
  gem 'turn', '~> 0.8.3', :require => false
  gem 'ruby-prof', '~> 0.11.2'  # For profiling
  #gem 'test-unit' # For profiling
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'jquery-rails', '2.1.4'
  gem 'therubyracer'
  gem 'less-rails'
  gem 'less-rails-bootstrap'
  gem 'less-rails-bootswatch'
  gem 'coffee-rails', '>= 3.1.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'less-rails-fontawesome'
end

#using this fork so that error messages with html will display properly
gem 'dynamic_form', :git => 'git://github.com/tmooney3979/dynamic_form'

gem 'devise', "~> 2.2.0"
gem 'cancan'
gem 'carmen'
gem 'will_paginate', '~> 3.0'
gem 'prawn'
gem "paperclip", "~> 3.0"
gem "capistrano"
gem 'rvm-capistrano', '>= 1.1.0'
gem 'acts_as_indexed'
gem 'foreman'
gem 'sidekiq'
gem 'aws-sdk'

