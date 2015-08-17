web: bundle exec puma -C ./config/puma.rb -e $RAILS_ENV -b unix:///tmp/neighbormarket.sock
worker: bundle exec sidekiq -e $RAILS_ENV -t 8 -c 5