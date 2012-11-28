# Rakefile
require_relative 'active_record_wrapper'

namespace :session_cleaner do
  include ActiveRecordWrapper
  desc "Cleans out old sessions"
  task :clean do
    Session.destroy_all( ['updated_at <?', 1.hour.ago] )
  end
end