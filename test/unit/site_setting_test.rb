require 'test_helper'

class SiteSettingTest < ActiveSupport::TestCase
  
   test "should not validate zip if invalid zip" do
     site_setting = SiteSetting.new(:drop_point_zip => 1234, :delivery => true, :drop_point => false)
     assert !site_setting.valid?, site_setting.errors.inspect
   end
   
   test "should not validate if no mode is enabled" do
     site_setting = SiteSetting.new(:delivery => false, :drop_point => false)
     assert !site_setting.valid?, site_setting.errors.inspect
   end
   
   test "should not validate if require_terms_of_service is true and terms_of_service is blank" do
     site_setting = SiteSetting.new(:delivery => false, :drop_point => true, :terms_of_service => "", :require_terms_of_service => true)
     assert !site_setting.valid?, site_setting.errors.inspect
   end
   
   test "should not validate if enable_facebook is true but facebook_app_id is blank" do
     site_setting = SiteSetting.new(:delivery => false, :drop_point => true, :facebook_enabled => true, :facebook_app_id => "")
     assert !site_setting.valid?, site_setting.errors.inspect
   end
   
   test "new_setting returns new site_settings" do
     settings = { "site_name" => "Test", "drop_point_address" => "123 Test St.", "drop_point_city" => "Portland", "drop_point_state" => "Oregon", "drop_point_zip" => "97218"}
     result = SiteSetting.new_setting(settings)
     
     assert_not_nil(result)
   end
   
   test "delivery_only returns true when site is set for delivery only" do
     settings = site_settings(:one)
     settings.update_attributes({:delivery => true, :drop_point => false})
     
     result = settings.delivery_only?
     
     assert(result)
   end
  
   test "drop_point_only returns true when site is set for drop_point only" do
     settings = site_settings(:one)
     settings.update_attributes({:delivery => false, :drop_point => true})
     
     result = settings.drop_point_only?
     
     assert(result)
   end
  
   test "all_modes returns true when site is set for drop_point and delivery" do
     settings = site_settings(:one)
     settings.update_attributes({:delivery => true, :drop_point => true})
     
     result = settings.all_modes?
     
     assert(result)
   end
  
  
   test "site_mode returns delivery when site is set for delivery only" do
     settings = site_settings(:one)
     settings.update_attributes({:delivery => true, :drop_point => false})
     
     result = settings.site_mode
     
     assert_equal("delivery", result)
   end
  
   test "site_mode returns drop_point when site is set for drop_point only" do
     settings = site_settings(:one)
     settings.update_attributes({:delivery => false, :drop_point => true})
     
     result = settings.site_mode
     
     assert_equal("drop_point", result)
   end
  
   test "site_mode returns all when site is set for drop_point and delivery" do
     settings = site_settings(:one)
     settings.update_attributes({:delivery => true, :drop_point => true})
     
     result = settings.site_mode
     
     assert_equal("all", result)
   end
  
end
