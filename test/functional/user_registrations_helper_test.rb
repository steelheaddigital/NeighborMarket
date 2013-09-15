require 'test_helper'

class UserRegistrationsHelperTest < ActionView::TestCase
  
  test "delivery_instructions_message returns correct message when site is set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => false)
    
    result = delivery_instructions_message(site_settings)
    
    assert_equal("<h5>Please add delivery instructions to your profile. Your delivery address is the address you have already entered when you set up your seller profile.</h5>".html_safe, result)
  end
  
  test "delivery_instructions_message returns correct message when site is set to all modes enabled" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => true)
    
    result = delivery_instructions_message(site_settings)
    
    assert_equal("<h5>If you would like to have the option of having your orders delivered, please enter delivery instructions now, otherwise you will need to pick up your order at the drop point. Your delivery address is the address you have already entered when you set up your seller profile.</h5>".html_safe, result)
  end
  
  test "delivery_instructions_message returns correct message when site is set to drop point only" do
    site_settings = SiteSetting.new(:delivery => false, :drop_point => true)
    
    result = delivery_instructions_message(site_settings)
    
    assert_equal("<h5> We have all the information we need to create your buyer account! Just click the update button to confirm. </h5>".html_safe, result)
  end
  
  test "delivery instructions label returns correct label when site is set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => false)
    
    result = delivery_instructions_label(site_settings)
    
    assert_equal("Delivery Instructions*", result)
  end
  
  test "delivery instructions label returns correct label when site is not set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => true)
    
    result = delivery_instructions_label(site_settings)
    
    assert_equal("Delivery Instructions", result)
  end
  
  test "address field label returns correct label when site is set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => false)
    
    result = field_label(:address, site_settings)
    
    assert_equal("Delivery Address*", result)
  end
  
  test "city field label returns correct label when site is set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => false)
    
    result = field_label(:city, site_settings)
    
    assert_equal("Delivery City*", result)
  end
  
  test "state field label returns correct label when site is set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => false)
    
    result = field_label(:state, site_settings)
    
    assert_equal("Delivery State*", result)
  end
  
  test "country field label returns correct label when site is set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => false)
    
    result = field_label(:country, site_settings)
    
    assert_equal("Delivery Country*", result)
  end
  
  test "zip field label returns correct label when site is set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => false)
    
    result = field_label(:zip, site_settings)
    
    assert_equal("Delivery Zip*", result)
  end
  
  
  test "address field label returns correct label when site is not set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => true)
    
    result = field_label(:address, site_settings)
    
    assert_equal("Delivery Address", result)
  end
  
  test "city field label returns correct label when site is not set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => true)
    
    result = field_label(:city, site_settings)
    
    assert_equal("Delivery City", result)
  end
  
  test "state field label returns correct label when site is not set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => true)
    
    result = field_label(:state, site_settings)
    
    assert_equal("Delivery State", result)
  end
  
  test "country field label returns correct label when site is not set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => true)
    
    result = field_label(:country, site_settings)
    
    assert_equal("Delivery Country", result)
  end
  
  test "zip field label returns correct label when site is not set to delivery only" do
    site_settings = SiteSetting.new(:delivery => true, :drop_point => true)
    
    result = field_label(:zip, site_settings)
    
    assert_equal("Delivery Zip", result)
  end
  
  
  
  test "address field label returns correct label when site is set to drop point only" do
    site_settings = SiteSetting.new(:delivery => false, :drop_point => true)
    
    result = field_label(:address, site_settings)
    
    assert_equal("Address", result)
  end
  
  test "city field label returns correct label when site is not set to drop point only" do
    site_settings = SiteSetting.new(:delivery => false, :drop_point => true)
    
    result = field_label(:city, site_settings)
    
    assert_equal("City", result)
  end
  
  test "state field label returns correct label when site is not set to drop point only" do
    site_settings = SiteSetting.new(:delivery => false, :drop_point => true)
    
    result = field_label(:state, site_settings)
    
    assert_equal("State", result)
  end
  
  test "country field label returns correct label when site is not set to drop point only" do
    site_settings = SiteSetting.new(:delivery => false, :drop_point => true)
    
    result = field_label(:country, site_settings)
    
    assert_equal("Country", result)
  end
  
  test "zip field label returns correct label when site is not set to drop point only" do
    site_settings = SiteSetting.new(:delivery => false, :drop_point => true)
    
    result = field_label(:zip, site_settings)
    
    assert_equal("Zip", result)
  end
  
end