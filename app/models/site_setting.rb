class SiteSetting < ActiveRecord::Base
  
  validates_format_of :domain, 
                      :with => URI::regexp(%w(http https)),
                      :message => "Should be like http://mysite.com"
  validates_format_of :drop_point_zip,
                      :with => %r{\d{5}(-\d{4})?},
                      :message => "should be like 12345 or 12345-1234"
  
  attr_accessible  :domain, :site_name, :drop_point_address, :drop_point_city, :drop_point_state, :drop_point_zip
  
  def self.new_setting(settings)
    current_site_settings = self.first
    if current_site_settings
      current_site_settings.assign_attributes(settings)
      return current_site_settings
    else
      new_settings = self.new(settings)
      return new_settings
    end
  end
  
end
