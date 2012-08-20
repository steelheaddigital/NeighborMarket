 class Scheduler
    require 'rubygems'
    require 'rufus/scheduler'
    require 'rails'
    
    def self.start
      @scheduler = Rufus::Scheduler.start_new
      start_session_cleaner
      
      puts "Scheduler started"
      Rails.logger.info "Scheduler started at " + DateTime.now.to_s
      
      @scheduler.join
    end
        
    def self.start_session_cleaner      
      @scheduler.every("1m") do
          Session.destroy_all( ['updated_at <?', 1.hour.ago] )
      end
    end
  end



