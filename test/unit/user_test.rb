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
                       :aboutme => "Test",
                       :delivery_instructions => "Test",
                       :payment_instructions => "Test",
                       :approved_seller => false,                   
                       :listing_approval_style => "manual")
     
   end
   
   test "should validate valid user" do
     assert @user.valid?
   end
   
   test "should not save user without user name" do
     @user.username = nil
    
     assert !@user.valid?
   end
   
   test "should not save user without first name" do
     @user.first_name = nil

     assert !@user.valid?
   end
   
   test "should not save user without last name" do
     @user.last_name = nil
     
     assert !@user.valid?
   end
   
   test "should not save user without Initial" do
     @user.initial = nil
     
     assert !@user.valid?
   end

   test "should not save user without Address" do
     @user.address = nil
     
     assert !@user.valid?
   end

   test "should not save user without City" do
     @user.city = nil
     
     assert !@user.valid?
   end
   
   test "should not save user without Zip" do
     @user.zip = nil
     
     assert !@user.valid?
   end
  
   test "should not save user without State" do
     @user.state = nil
     
     assert !@user.valid?
   end
   
   test "should not save user without Country" do
     @user.country = nil
     
     assert !@user.valid?
   end
  
   test "should not save user with invalid zip" do
     @user.zip = "Foo"
     
     assert !@user.valid?
   end  
  
   test "should not save Buyer without delivery instructions" do
     new_role = Role.new
     new_role.name = "buyer"
     @user.roles.build(new_role.attributes)
     @user.delivery_instructions = nil
     
     assert !@user.valid?
   end

   test "should not save seller without payment instructions" do     
     new_role = Role.new
     new_role.name = "seller"
     @user.roles.build(new_role.attributes)
     @user.payment_instructions = nil
     
     assert !@user.valid?
   end 

   test "should not save seller without phone number" do
     @user.phone = nil
     new_role = Role.new
     new_role.name = "seller"
     @user.roles.build(new_role.attributes)

     assert !@user.valid?
   end
   
   test "should not save seller with invalid phone number" do
     @user.phone = "Foo"
     new_role = Role.new
     new_role.name = "seller"
     @user.roles.build(new_role.attributes)
     
     assert !@user.valid?
   end
   
   test "should save user other than seller without phone" do
     @user.phone = nil
     new_role = Role.new
     new_role.name = "buyer"
     @user.roles.build(new_role.attributes)
     
     assert @user.valid?
   end
   
   test "should not save existing user without password and password confirmation if auto_created and not yet updated" do
    user = users(:auto_created_user)
    user.password = ''
    user.password_confirmation = ''
   
    assert !user.valid?
   end
   
   test "updates auto_create_updated_at on update for valid auto created user" do
    user = users(:confirmed_auto_created_user)
    user.update_attributes(:password => "Abc123!", :password_confirmation => "Abc123!")
    
    assert user.valid?
    assert !user.auto_create_updated_at.nil?
   end
   
   test "does not update auto_create_updated_at on update if user is not valid" do
    user = users(:confirmed_auto_created_user)
    user.update_attributes(:password => "Abc123!", :password_confirmation => "")
    
    assert !user.valid?
    assert user.auto_create_updated_at.nil?
   end
   
   test "auto_created_pending_update returns true if user is auto created and not updated" do
    user = users(:confirmed_auto_created_user)
    
    assert user.auto_created_pending_update?
   end
   
   test "pending_reconfirmation? returns true if user is auto created and not updated" do
    user = users(:confirmed_auto_created_user)
    
    assert user.pending_reconfirmation?
   end
   
   test "should not save new user without password and password confirmation" do
    @user.password = nil
    @user.password_confirmation = nil
   
    assert !@user.valid?
   end
   
   test "should not save new user with password of invalid length" do
    @user.password = '12345'
    @user.password_confirmation = '12345'
   
    assert !@user.valid?
   end
   
   test "should not save new user without password confirmation" do
    @user.password = '123456'
    @user.password_confirmation = ''
   
    assert !@user.valid?
   end
   
   test "should not save new user without email" do
    @user.email = ''
   
    assert !@user.valid?
   end
   
   test "should not save new user without unique email" do
    @user.email = "test@test.com"
   
    assert !@user.valid?
   end
   
   test "should not save new user with invalid email format" do
    @user.email = "test.test.com"
   
    assert !@user.valid?
   end
   
   test "should save user without password and password confirmation if not a new user and not auto_created pending update" do
    user = users(:approved_seller_user)
    user.password = nil
    user.password_confirmation = nil
    
    assert user.valid?
   end
   
   test "should save user without password and password confirmation if auto_created but updated" do
    user = users(:updated_auto_created_user)
    user.password = nil
    user.password_confirmation = nil
    
    assert user.valid?
   end
   
   test "should not save user other than seller with invalid phone" do
     @user.phone = "Foo"
     new_role = Role.new
     new_role.name = "buyer"
     @user.roles.build(new_role.attributes)
     
     assert !@user.valid?
   end
   
  test "active_for_authentication? returns true if seller is approved" do
     user = users(:approved_seller_user)
     
     assert user.seller?
     result = user.active_for_authentication?
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
    
     assert user.buyer?
     assert result

  end
  
  test "active_for_authentication? returns true if seller is unapproved and also a buyer" do
     
     user = users(:unapproved_seller_buyer_user)
    
     result = user.active_for_authentication?
     
     assert user.buyer?
     assert user.seller?
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
    
     assert user.buyer?
     assert user.seller?
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
  
  test "buyer? returns true if user is buyer " do
    
    user = users(:buyer_user)
    
    result = user.buyer?
    
    assert result
    
  end
  
  test "manager? returns true if user is manager " do
    
    user = users(:manager_user)
    
    result = user.manager?
    
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
  
  test "auto_create creates user with email only" do
    user = User.new(:email => "someuser@test.com")
    result = false
    assert_difference "User.count" do
      result = user.auto_create_user
    end
    assert result
    assert user.auto_created
    assert user.auto_create_updated_at.nil?
  end

  test "soft_delete deletes appropriate fields" do
    user = users(:approved_seller_user)
    
    user.soft_delete
    
    assert_not_nil user.deleted_at
    assert_equal("", user.email)
    assert_nil user.password
    assert_nil user.reset_password_token
    assert_nil user.reset_password_sent_at
    assert_nil user.remember_created_at
    assert_equal(0, user.sign_in_count)
    assert_nil user.current_sign_in_at
    assert_nil user.last_sign_in_at
    assert_nil user.current_sign_in_ip
    assert_nil user.last_sign_in_ip
    assert_nil user.created_at
    assert_nil user.updated_at
    assert_nil user.first_name
    assert_nil user.last_name
    assert_nil user.initial
    assert_nil user.phone
    assert_nil user.address
    assert_nil user.city
    assert_nil user.state
    assert_nil user.country
    assert_nil user.zip
    assert_nil user.aboutme
    assert_nil user.delivery_instructions
    assert_nil user.payment_instructions
    assert !user.approved_seller
    assert_equal("", user.listing_approval_style)
    assert_equal([], user.roles)
    
  end

end
