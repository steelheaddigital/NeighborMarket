require 'test_helper'

class SiteSettingTest < ActiveSupport::TestCase

   test "should not validate domain if invalid url" do
     site_setting = SiteSetting.new(:domain => "http:test.com")
     assert !site_setting.valid?, site_setting.errors.inspect
   end
  
   test "should not validate domain if invalid zip" do
     site_setting = SiteSetting.new(:zip => 1234)
     assert !site_setting.valid?, site_setting.errors.inspect
   end
   
   test "new_setting returns new site_settings" do
     settings = {"domain" => "http://mysite.com", "site_name" => "Test", "drop_point_address" => "123 Test St.", "drop_point_city" => "Portland", "drop_point_state" => "Oregon", "drop_point_zip" => "97218"}
     result = SiteSetting.new_setting(settings)
     
     assert_not_nil(result)
   end
  
end