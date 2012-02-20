# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.delete_all
user = User.new(
  :username => "manager",
  :email => "manager@manage.com",
  :password   => 'Abc123!', 
  :password_confirmation => 'Abc123!', 
  :first_name => "Test",
  :last_name => "Manager",
  :initial => "M",
  :phone => "503-123-4567",
  :address => "123 Test St.",
  :state => "OR",
  :country => "USA",
  :zip => "97218"
)

Manager.create
buyer = Buyer.new(
  :delivery_instructions => "Blah"
)
buyer.save(:validate => false)

user.roles.build(
  :rolable_id => 1,
  :rolable_type => "Manager"
)

user.roles.build(
  :rolable_id => 1,
  :rolable_type => "Buyer"
)

user.save(:validate => false)




