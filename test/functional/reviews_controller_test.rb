require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:buyer_user)
    sign_in @user
  end
  
  test "should get new review" do
    item = inventory_items(:one)
    
    get :new, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    
    assert_not_nil assigns(:reviewable_type)
    assert_not_nil assigns(:reviewable_id)
    assert_not_nil assigns(:reviewable)
    assert_not_nil assigns(:review)
    assert_response :success
  end
  
  test "should get new reviewjs" do
    item = inventory_items(:one)
    
    get :new, :reviewable_id => item.id, :reviewable_type => "InventoryItem", :format => 'js'
    
    assert_not_nil assigns(:reviewable_type)
    assert_not_nil assigns(:reviewable_id)
    assert_not_nil assigns(:reviewable)
    assert_not_nil assigns(:review)
    assert_response :success
    assert_equal response.content_type, Mime::JS
  end
  
  test "should create review" do
    item = inventory_items(:one)
    
    post :create, :reviewable_id => item.id, :reviewable_type => "InventoryItem", :review => { :rating => 5, :review => "Blah Blah Blah", :user_id => @user.id }
    
    assert_not_nil assigns(:reviewable_type)
    assert_not_nil assigns(:reviewable_id)
    assert_not_nil assigns(:reviewable)
    assert_not_nil assigns(:review)
    assert_redirected_to user_reviews_inventory_items_url
    assert_equal 5, item.reviews.where(user_id: @user.id).last.rating
  end
  
  test "should create review js" do
    item = inventory_items(:one)
    
    post :create, :format => 'js', :reviewable_id => item.id, :reviewable_type => "InventoryItem", :review => { :rating => 5, :review => "Blah Blah Blah", :user_id => @user.id }
    
    assert_not_nil assigns(:reviewable_type)
    assert_not_nil assigns(:reviewable_id)
    assert_not_nil assigns(:reviewable)
    assert_not_nil assigns(:review)
    assert_redirected_to user_reviews_inventory_items_url
    assert_equal 5, item.reviews.where(user_id: @user.id).last.rating
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get edit" do 
    review = reviews(:one)
    item = inventory_items(:one)
    
    get :edit, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    
    assert_not_nil assigns(:reviewable_type)
    assert_not_nil assigns(:reviewable_id)
    assert_not_nil assigns(:reviewable)
    assert_not_nil assigns(:review)
    assert_response :success
  end
  
  test "should get edit js" do 
    review = reviews(:one)
    item = inventory_items(:one)
    
    get :edit, :format => 'js', :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    
    assert_not_nil assigns(:reviewable_type)
    assert_not_nil assigns(:reviewable_id)
    assert_not_nil assigns(:reviewable)
    assert_not_nil assigns(:review)
    assert_response :success
    assert_equal response.content_type, Mime::JS
  end
  
  test "should update review" do
    item = inventory_items(:one)
    review = reviews(:one)
    
    post :update, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem", :review => { :rating => 5, :review => "Blah Blah Blah", :user_id => @user.id }
    
    assert_not_nil assigns(:reviewable_type)
    assert_not_nil assigns(:reviewable_id)
    assert_not_nil assigns(:reviewable)
    assert_not_nil assigns(:review)
    assert_redirected_to user_reviews_inventory_items_url
    assert_equal 5, item.reviews.where(id: review.id).first.rating
  end
  
  test "should update review js" do
    item = inventory_items(:one)
    review = reviews(:one)
    
    post :update, :format => 'js', :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem", :review => { :rating => 5, :review => "Blah Blah Blah", :user_id => @user.id }
    
    assert_not_nil assigns(:reviewable_type)
    assert_not_nil assigns(:reviewable_id)
    assert_not_nil assigns(:reviewable)
    assert_not_nil assigns(:review)
    assert_redirected_to user_reviews_inventory_items_url
    assert_equal 5, item.reviews.where(id: review.id).first.rating
    assert_equal response.content_type, Mime::JS
  end
  
  test "should destroy review" do
    item = inventory_items(:one)
    review = reviews(:one)
    
    assert_difference 'Review.count', -1 do
      post :destroy, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    end
    
    assert_not_nil assigns(:reviewable_type)
    assert_not_nil assigns(:reviewable_id)
    assert_not_nil assigns(:reviewable)
    assert_not_nil assigns(:review)
    assert_redirected_to user_reviews_inventory_items_url
  end
  
  test "user cannot review items that they have not purchased" do
    sign_out @user
    @user  = users(:approved_seller_user)
    sign_in @user
    item = inventory_items(:two)
    review = reviews(:one)
    
    post :create, :reviewable_id => item.id, :reviewable_type => "InventoryItem", :review => { :rating => 5, :review => "Blah Blah Blah" }
    assert_response :not_found

    get :new, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    assert_response :not_found
    
    get :edit, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    assert_response :not_found
    
    post :update, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem", :review => { :rating => 5, :review => "Blah Blah Blah", :user_id => @user.id }
    assert_response :not_found
    
    post :destroy, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    assert_response :not_found
    
  end
  
  test "seller cannot review their own item" do
    sign_out @user
    @user  = users(:approved_seller_user)
    sign_in @user
    item = inventory_items(:one)
    review = reviews(:one)
    
    post :create, :reviewable_id => item.id, :reviewable_type => "InventoryItem", :review => { :rating => 5, :review => "Blah Blah Blah" }
    assert_response :not_found

    get :new, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    assert_response :not_found
    
    get :edit, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    assert_response :not_found
    
    post :update, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem", :review => { :rating => 5, :review => "Blah Blah Blah", :user_id => @user.id }
    assert_response :not_found
    
    post :destroy, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    assert_response :not_found
    
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    item = inventory_items(:one)
    review = reviews(:one)

    post :create, :reviewable_id => item.id, :reviewable_type => "InventoryItem", :review => { :rating => 5, :review => "Blah Blah Blah" }
    assert_redirected_to new_user_session_path

    get :new, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    assert_redirected_to new_user_session_path
    
    get :edit, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    assert_redirected_to new_user_session_path
    
    post :update, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem", :review => { :rating => 5, :review => "Blah Blah Blah", :user_id => @user.id }
    assert_redirected_to new_user_session_path
    
    post :destroy, :id => review.id, :reviewable_id => item.id, :reviewable_type => "InventoryItem"
    assert_redirected_to new_user_session_path
  end
  
end