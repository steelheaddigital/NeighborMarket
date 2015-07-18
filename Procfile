web: bundle exec puma -C ./config/puma.rb -e $RAILS_ENV -b unix:///tmp/neighbormarket.sock
worker: bundle exec rake jobs:work RAILS_ENV=$RAILS_ENV