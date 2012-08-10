# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'rufus/scheduler'  
scheduler = Rufus::Scheduler.start_new
scheduler.every("1m") do
    Session.destroy_all( ['updated_at <?', 1.hour.ago] )
end
