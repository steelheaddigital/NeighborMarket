require 'test_helper'

class UserTest < ActiveSupport::TestCase
   
   def setup
     @user = User.new(:email => "test@example.com",
                      :password => "Abc123!",
                      :password_confirmation => "Abc123!",
                       :username => "Test",
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
     
   end
  
   test "should not save user without user name" do
     @user.username = nil
    
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user without first name" do
     @user.first_name = nil

     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user without last name" do
     @user.last_name = nil
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user without Initial" do
     @user.initial = nil
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end

   test "should not save user without Address" do
     @user.address = nil
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end

   test "should not save user without City" do
     @user.city = nil
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user without Zip" do
     @user.zip = nil
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
  
   test "should not save user without State" do
     @user.state = nil
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user without Country" do
     @user.country = nil
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
  
   test "should not save user with invalid zip" do
     @user.zip = "Foo"
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end  
  
   test "should not save Buyer without delivery instructions" do
     role = @user.roles.new
     role.rolable = Buyer.new(:delivery_instructions => nil)
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end

   test "should not save seller without payment instructions" do
     role = @user.roles.new
     role.rolable = Seller.new(:payment_instructions => nil)
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end 

   test "should not save seller without phone number" do
     @user.phone = nil
     role = @user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")

     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save seller with invalid phone number" do
     @user.phone = "Foo"
     role = @user.roles.new
     role.rolable = Seller.new(:payment_instructions => "Pay Me")
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should save user other than seller without phone" do
     @user.phone = nil
     role = @user.roles.new
     role.rolable = Buyer.new(:delivery_instructions => "Bring me the stuff.")
     
     assert @user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
   test "should not save user other than seller with invalid phone" do
     @user.phone = "Foo"
     role = @user.roles.new
     role.rolable = Buyer.new(:delivery_instructions => "Bring me the stuff.")
     
     assert !@user.valid?
     
     @user.errors.each do |error|
       Rails::logger.debug error.to_s
     end
   end
   
  test "active_for_authentication? returns true if seller is approved" do
     
     user = users(:approved_seller_user)
    
     result = user.active_for_authentication?
     
     assert user.seller?
     assert result

  end
  
  test "active_for_authentication? returns false if seller is not approved" do
    
    user = users(:unapproved_seller_user)
     
     result = user.active_for_authentication?
    
     assert user.seller?
     assert !result

  end
  
  test "active_for_authentication? returns true if user is buyer" do
     
     user = users(:buyer_user)
    
     result = user.active_for_authentication?
    
     assert user.role?("Buyer")
     assert result

  end
  
  test "active_for_authentication? returns true if seller is unapproved and also a buyer" do
     
     user = users(:unapproved_seller_buyer_user)
    
     result = user.active_for_authentication?
    
     assert user.role?("Buyer")
     assert user.role?("Seller")
     assert result

  end
  
  test "inactive_message returns message if seller not approved" do
     
     user = users(:unapproved_seller_user)
    
     result = user.inactive_message
    
     assert_equal(result, :not_approved)

  end
  
  test "inactive_message does not return message if seller not approved and also a buyer" do
    
     user = users(:unapproved_seller_buyer_user)
    
     result = user.active_for_authentication?
    
     assert user.role?("Buyer")
     assert user.role?("Seller")
     assert_not_equal(result, :not_approved)

  end
  
  test "seller? returns true if become_seller is true " do
   
    user = users(:buyer_user)
    user.become_seller = true
    
    result = user.seller?
    
    assert result
    
  end
  
  test "seller? returns true if user is seller " do
    
    user = users(:unapproved_seller_buyer_user)
    
    result = user.seller?
    
    assert result
    
  end
  
  test "approved seller? returns true if user is an approved seller " do
   
    user = users(:approved_seller_user)
    
    result = user.approved_seller?
    
    assert result
    
  end
  
  test "approved_seller? returns false if user is not an approved seller " do
    
    user = users(:unapproved_seller_buyer_user)
    
    result = user.approved_seller?
    
    assert !result
    
  end
  
end
