User.transaction do
    seller = User.new(
    :username => "Seller1",
    :email => "seller1@test.com",
    :password   => 'Abc123!', 
    :password_confirmation => 'Abc123!', 
    :first_name => "Seller",
    :last_name => "One",
    :phone => "503-123-4567",
    :address => "123 Test St.",
    :city => "Portland",
    :state => "Oregon",
    :country => "United States",
    :zip => "97218",
    :payment_instructions => "Pay me please",
    :approved_seller => "true",
    :listing_approval_style => "auto"
  )

  seller_role = Role.new
  seller_role.name = "seller"
  seller.roles << seller_role

  seller.skip_confirmation!
  seller.save(:validate => false)

end

User.transaction do
    buyer = User.new(
    :username => "Buyer1",
    :email => "buyer1@test.com",
    :password   => 'Abc123!', 
    :password_confirmation => 'Abc123!', 
    :first_name => "Buyer",
    :last_name => "One",
    :phone => "503-123-4567",
    :address => "123 Test St.",
    :city => "Portland",
    :state => "Oregon",
    :country => "United States",
    :zip => "97218",
    :delivery_instructions => "Bring me the stuff"
  )

  buyer_role = Role.new
  buyer_role.name = "buyer"
  buyer.roles << buyer_role

  buyer.skip_confirmation!
  buyer.save(:validate => false)
end
