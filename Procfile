web: bundle exec unicorn -c ./config/unicorn.rb -E $RAILS_ENV
worker: bundle exec rake jobs:work RAILS_ENV=$RAILS_ENV