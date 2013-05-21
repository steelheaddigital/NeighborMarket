#
#Copyright 2013 Neighbor Market
#
#This file is part of Neighbor Market.
#
#Neighbor Market is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Neighbor Market is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
#

module CrowdMap
  
  require "net/http"
  require "rails"
  
  class CrowdMap < Rails::Railtie
    
    def self.post_item_to_crowdmap(inventory_item)

      t = Time.now

      name = item_name(inventory_item)
      description = inventory_item.description
      date = t.strftime("%m/%d/%Y")
      hour = t.strftime("%I")
      minute = t.min.to_s
      ampm = t.strftime("%p").downcase
      location = inventory_item.user.address
      first_name = inventory_item.user.first_name
      last_name = inventory_item.user.last_name
      email = inventory_item.user.email

      data = {'task' => 'report', 'incident_title' => name, 'incident_description' => description, 'incident_date' => date, 'incident_hour' => hour, 'incident_minute' => minute, 'incident_ampm' => ampm, 'incident_category' => '1', 'latitude' => '45.557037', 'longitude' => '-122.592990', 'location_name' => location, 'person_first' => first_name, 'person_last' => last_name, 'person_email' => email}
      
      url = URI(config.crowdmap_url)

      req = Net::HTTP::Post.new(url.request_uri)
      req.set_form_data(data)

      res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
        http.request(req)
      end

      code = res.body
    end
    
      
    def item_name(inventory_item)

        if(inventory_item.name == nil || inventory_item.name == "")
          inventory_item.second_level_category.name 
        else
          inventory_item.name
        end  

    end
    
  end
  
end