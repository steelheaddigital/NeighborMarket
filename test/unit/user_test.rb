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
     role = user.roles.build
     role.build_seller
     role.seller.payment_instructions = "Pay me"
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
     role = user.roles.build
     role.build_seller
     role.seller.payment_instructions = "Pay me"
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
     role = user.roles.build
     role.build_seller
     role.seller.payment_instructions = "Pay me"
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
     role = user.roles.build
     role.build_seller
     role.seller.payment_instructions = "Pay me"
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
     role = user.roles.build
     role.build_seller
     role.seller.payment_instructions = "Pay me"
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
     role = user.roles.build
     role.build_seller
     role.seller.payment_instructions = "Pay me"
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
     role = user.roles.build
     role.build_seller
     role.seller.payment_instructions = "Pay me"
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
     role = user.roles.build
     role.build_seller
     role.seller.payment_instructions = "Pay me"
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
     role = user.roles.build
     role.build_buyer
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
     role = user.roles.build
     role.build_seller
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end 

   test "should not save user with invalid phone number" do
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
     role = user.roles.build
     role.build_seller
     role.seller.payment_instructions = "Pay me"
     assert !user.save
     
     user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end    
end
