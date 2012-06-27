require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
   test "should not save user without user name" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => nil,
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "T",
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me") 
    
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user without first name" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => nil,
                       :last_name => "Test",
                       :initial => "T",
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user without last name" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => nil,
                       :initial => "T",
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user without Initial" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => nil,
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end

   test "should not save user without Address" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => "503-123-4567",
                       :address => nil,
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end

   test "should not save user without City" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => nil,
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user without Zip" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => nil,
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
  
   test "should not save user without State" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => nil,
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user without Country" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => nil,
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
  
   test "should not save user with invalid zip" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "Foo",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end  
  
   test "should not save Buyer without delivery instructions" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Buyer.new(:delivery_instructions => nil)
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end

   test "should not save seller without payment instructions" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => "503-123-4567",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => nil)
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end 

   test "should not save seller without phone number" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => nil,
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")

     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save seller with invalid phone number" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => "Foo",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should save user other than seller without phone" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => nil,
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Buyer.new(:delivery_instructions => "Bring me the stuff.")
     
     assert user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user other than seller with invalid phone" do
     user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "test",
                       :first_name => "Test",
                       :last_name => "Test",
                       :initial => "I",
                       :phone => "Test",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :aboutme => "Test")
     role = user.roles.new
     role.rolable = Buyer.new(:delivery_instructions => "Bring me the stuff.")
     
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
  test "active_for_authentication? returns true if seller is approved" do
     
     #user id 2 is an approved seller
     user = User.find(2)
    
     result = user.active_for_authentication?
     
     assert user.seller?
     assert result

  end
  
  test "active_for_authentication? returns false if seller is not approved" do
    
     #user id 3 is an unapproved seller
     user = User.find(3)
     
     result = user.active_for_authentication?
    
     assert user.seller?
     assert !result

  end
  
  test "active_for_authentication? returns true if user is buyer" do
     
    #user id 4 is a buyer
     user = User.find(4)
    
     result = user.active_for_authentication?
    
     assert user.role?("Buyer")
     assert result

  end
  
  test "active_for_authentication? returns true if seller is unapproved and also a buyer" do
     
     #user id 5 is both an unapproved seller and a buyer
     user = User.find(5)
    
     result = user.active_for_authentication?
    
     assert user.role?("Buyer")
     assert user.role?("Seller")
     assert result

  end
  
  test "inactive_message returns message if seller not approved" do
     
    #user id 4 is a buyer
     user = User.find(3)
    
     result = user.inactive_message
    
     assert_equal(result, :not_approved)

  end
  
  test "inactive_message does not return message if seller not approved and also a buyer" do
     
    #user id 5 is both an unapproved seller and a buyer
     user = User.find(5)
    
     result = user.active_for_authentication?
    
     assert user.role?("Buyer")
     assert user.role?("Seller")
     assert_not_equal(result, :not_approved)

  end
  
  test "seller? returns true if become_seller is true " do
    
    #user id 4 is a buyer
    user = User.find(4)
    user.become_seller = true
    
    result = user.seller?
    
    assert result
    
  end
  
  test "seller? returns true if user is seller " do
    
    #user id 5 is both an unapproved seller and a buyer
    user = User.find(5)
    
    result = user.seller?
    
    assert result
    
  end
  
  test "approved seller? returns true if user is an approved seller " do
    
    #user id 2 is an approved seller
    user = User.find(2)
    
    result = user.approved_seller?
    
    assert result
    
  end
  
  test "approved_seller? returns false if user is not an approved seller " do
    
    #user id 5 is both an unapproved seller and a buyer
    user = User.find(5)
    
    result = user.approved_seller?
    
    assert !result
    
  end
  
end
