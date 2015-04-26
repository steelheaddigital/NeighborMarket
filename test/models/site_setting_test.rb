require 'test_helper'

class SiteSettingTest < ActiveSupport::TestCase
  
   test "should not validate zip if invalid zip" do
     site_setting = SiteSetting.instance
     site_setting.update(:drop_point_zip => 1234, :delivery => true, :drop_point => false)
     assert !site_setting.valid?, site_setting.errors.inspect
   end
   
   test "should not validate if no mode is enabled" do
     site_setting = SiteSetting.instance
     site_setting.update(:delivery => false, :drop_point => false)
     assert !site_setting.valid?, site_setting.errors.inspect
   end
   
   test "should not validate if enable_facebook is true but facebook_app_id is blank" do
     site_setting = SiteSetting.instance
     site_setting.update(:delivery => false, :drop_point => true, :facebook_enabled => true, :facebook_app_id => "")
     assert !site_setting.valid?, site_setting.errors.inspect
   end
   
   test "should not validate if google_analytics_enabled is true but google_analytics_app_id is blank" do
     site_setting = SiteSetting.instance
     site_setting.update(:delivery => false, :drop_point => true, :google_analytics_enabled => true, :google_analytics_app_id => "")
     assert !site_setting.valid?, site_setting.errors.inspect
   end
   
   test "delivery_only returns true when site is set for delivery only" do
     settings = SiteSetting.instance
     settings.update({:delivery => true, :drop_point => false})
     
     result = settings.delivery_only?
     
     assert(result)
   end
  
   test "drop_point_only returns true when site is set for drop_point only" do
     settings = SiteSetting.instance
     settings.update({:delivery => false, :drop_point => true})
     
     result = settings.drop_point_only?
     
     assert(result)
   end
  
   test "all_modes returns true when site is set for drop_point and delivery" do
     settings = SiteSetting.instance
     settings.update({:delivery => true, :drop_point => true})
     
     result = settings.all_modes?
     
     assert(result)
   end
  
  
   test "site_mode returns delivery when site is set for delivery only" do
     settings = SiteSetting.instance
     settings.update({:delivery => true, :drop_point => false})
     
     result = settings.site_mode
     
     assert_equal("delivery", result)
   end
  
   test "site_mode returns drop_point when site is set for drop_point only" do
     settings = SiteSetting.instance
     settings.update({:delivery => false, :drop_point => true})
     
     result = settings.site_mode
     
     assert_equal("drop_point", result)
   end
  
   test "site_mode returns all when site is set for drop_point and delivery" do
     settings = SiteSetting.instance
     settings.update({:delivery => true, :drop_point => true})
     
     result = settings.site_mode
     
     assert_equal("all", result)
   end
  
end
