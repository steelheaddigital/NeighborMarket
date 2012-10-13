# Rakefile
namespace :session_cleaner do
  desc "Cleans out old sessions"
  task :clean => :environment do
    Session.destroy_all( ['updated_at <?', 1.hour.ago] )
  end
end