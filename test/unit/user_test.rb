require 'test_helper'

class UserTest < ActiveSupport::TestCase
   
   def setup
     @seller = User.new(:email => "test@example.com",
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
                       :listing_approval_style => "manual",
                       :terms_of_service => true)
  
     seller_role = Role.new
     seller_role.name = "seller"
     @seller.roles.build(seller_role.attributes)
     @seller.payment_instructions = "Pay Me"
     
     @buyer = User.new(:email => "buyer@example.com",
                       :password => "Abc123!",
                       :password_confirmation => "Abc123!",
                       :username => "TestBuyer",
                       :address => "12345 Test St.",
                       :city => "Portland",
                       :country => "United States",
                       :state => "Oregon",
                       :zip => "97218",
                       :delivery_instructions => "Test",
                       :terms_of_service => true)
  
     buyer_role = Role.new
     buyer_role.name = "buyer"
     @buyer.roles.build(buyer_role.attributes)
     @buyer.delivery_instructions = "Bring Me The Stuff"
   end
   
   test "should validate valid seller" do
     assert @seller.valid?
   end
   
   test "should validate valid buyer" do
     assert @buyer.valid?
   end
   
   test "should not validate if password confirmation does not equal password" do
     @seller.password_confirmation = 'blah'
    
     assert !@seller.valid?
     assert_equal("Password confirmation doesn't match Password", @seller.errors.full_messages.first)
   end
   
   test "should not save seller without user name" do
     @seller.username = nil
    
     assert !@seller.valid?
   end
   
   test "should not save seller without first name" do
     @seller.first_name = nil

     assert !@seller.valid?
   end
   
   test "should not save seller without last name" do
     @seller.last_name = nil
     
     assert !@seller.valid?
   end
   
   test "should save seller without Initial" do
     @seller.initial = nil
     
     assert @seller.valid?
   end

   test "should not save seller without Address" do
     @seller.address = nil
     
     assert !@seller.valid?
   end

   test "should not save seller without City" do
     @seller.city = nil
     
     assert !@seller.valid?
   end
   
   test "should not save seller without Zip" do
     @seller.zip = nil
     
     assert !@seller.valid?
   end
  
   test "should not save seller without State" do
     @seller.state = nil
     
     assert !@seller.valid?
   end
   
   test "should not save seller without Country" do
     @seller.country = nil
     
     assert !@seller.valid?
   end
  
   test "should not save seller with invalid zip" do
     @seller.zip = "Foo"
     
     assert !@seller.valid?
   end  

   test "should not save seller without payment instructions" do     
     @seller.payment_instructions = nil
     
     assert !@seller.valid?
   end 

   test "should not save seller without phone number" do
     @seller.phone = nil

     assert !@seller.valid?
   end
   
   test "should not save seller with invalid phone number" do
     @seller.phone = "Foo"
     
     assert !@seller.valid?
   end
   
   test "should save user other than seller without phone" do
     @buyer.phone = nil
     
     assert @buyer.valid?
   end
   
   
   test "should not save buyer without Address if delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => true, :drop_point => false, :require_terms_of_service => false })
     @buyer.address = nil
     
     assert !@buyer.valid?
   end

   test "should not save buyer without City if delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => true, :drop_point => false, :require_terms_of_service => false})
     @buyer.city = nil
     
     assert !@buyer.valid?
   end
   
   test "should not save buyer without Zip if delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => true, :drop_point => false, :require_terms_of_service => false})
     @buyer.zip = nil
     
     assert !@buyer.valid?
   end
  
   test "should not save buyer without State if delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => true, :drop_point => false, :require_terms_of_service => false})
     @buyer.state = nil
     
     assert !@buyer.valid?
   end
   
   test "should not save buyer without Country if delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => true, :drop_point => false, :require_terms_of_service => false})
     @buyer.country = nil
     
     assert !@buyer.valid?
   end
  
   test "should save buyer without Address if not delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => false, :drop_point => true, :require_terms_of_service => false})
     @buyer.address = nil
     
     assert @buyer.valid?
   end

   test "should save buyer without City if delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => false, :drop_point => true, :require_terms_of_service => false})
     @buyer.city = nil
     
     assert @buyer.valid?
   end
   
   test "should save buyer without Zip if not delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => false, :drop_point => true, :require_terms_of_service => false})
     @buyer.zip = nil
     
     assert @buyer.valid?
   end
  
   test "should save buyer without State if not delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => false, :drop_point => true, :require_terms_of_service => false})
     @buyer.state = nil
     
     assert @buyer.valid?
   end
   
   test "should save buyer without Country if not delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => false, :drop_point => true, :require_terms_of_service => false})
     @buyer.country = nil
     
     assert @buyer.valid?
   end
  
   test "should not save buyer with invalid zip" do
     @buyer.zip = "Foo"
     
     assert !@buyer.valid?
   end  
   
   test "should not save buyer without delivery instructions if delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => true, :drop_point => false, :require_terms_of_service => false})
     @buyer.delivery_instructions = nil
     
     assert !@buyer.valid?
   end  
   
   test "should save buyer without delivery instructions if not delivery only" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:delivery => false, :drop_point => true, :require_terms_of_service => false})
     @buyer.delivery_instructions = nil
     
     assert @buyer.valid?
   end  
   
   test "should not save existing user without password and password confirmation if auto_created and not yet updated" do
    user = users(:auto_created_user)
    user.password = ''
    user.password_confirmation = ''
   
    assert !user.valid?
   end
   
   test "updates auto_create_updated_at on update for valid auto created user" do
    user = users(:confirmed_auto_created_user)
    user.update_attributes(:password => "Abc123!", :password_confirmation => "Abc123!", :terms_of_service => true)
    
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
    @seller.password = nil
    @seller.password_confirmation = nil
   
    assert !@seller.valid?
   end
   
   test "should not save new user with password of invalid length" do
    @seller.password = '12345'
    @seller.password_confirmation = '12345'
   
    assert !@seller.valid?
   end
   
   test "should not save new user without password confirmation" do
    @seller.password = '123456'
    @seller.password_confirmation = ''
   
    assert !@seller.valid?
   end
   
   test "should not save new user without email" do
    @seller.email = ''
   
    assert !@seller.valid?
   end
   
   test "should not save new user without unique email" do
    @seller.email = "test@test.com"
   
    assert !@seller.valid?
   end
   
   test "should not save new user with invalid email format" do
    @seller.email = "test.test.com"
   
    assert !@seller.valid?
   end
   
   test "should not save new user without terms of service agreement" do
     site_setting = SiteSetting.first;
     site_setting.update_attributes({:require_terms_of_service => true})
     @seller.terms_of_service = false
     
     assert !@seller.valid?
   end
   
   test "should save new user without terms of service agreement if terms of service acceptance not required" do
     site_content = SiteContent.first;
     site_content.update_attributes({:require_terms_of_service => false})
     @seller.terms_of_service = false
     
     assert @seller.valid?
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
     @buyer.phone = "Foo"
     
     assert !@buyer.valid?
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

  test "add_role adds specified role to user" do
    user = User.new(:email => "someuser@test.com")
    user.add_role('manager')
    
    assert user.manager?
  end

  test "remove_role removes specified role from user" do
    user = users(:unapproved_seller_buyer_user)
    user.remove_role('seller')
    
    assert !user.seller?
  end

  test "soft_delete deletes appropriate fields" do
    user = users(:approved_seller_user)
    
    user.soft_delete
    
    assert_not_nil user.deleted_at
    assert_nil user.email
    assert_nil user.password
    assert_nil user.reset_password_token
    assert_nil user.reset_password_sent_at
    assert_nil user.remember_created_at
    assert_equal(0, user.sign_in_count)
    assert_nil user.current_sign_in_at
    assert_nil user.last_sign_in_at
    assert_nil user.current_sign_in_ip
    assert_nil user.last_sign_in_ip
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
