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
  :email => "gmpmanagertest@gmail.com",
  :password   => 'Abc123!', 
  :password_confirmation => 'Abc123!', 
  :first_name => "Test",
  :last_name => "Manager",
  :initial => "M",
  :phone => "503-123-4567",
  :address => "123 Test St.",
  :city => "Portland",
  :state => "Oregon",
  :country => "United States",
  :zip => "97218"
)

manager_role = Role.new
manager_role.name = "manager"
user.roles << manager_role

user.skip_confirmation!
user.save(:validate => false)

vegetable = TopLevelCategory.new(
  :name => 'Vegetable',
  :description => 'Vegetables'
)

vegetable.second_level_categories.build([
    { :name => 'Carrot',
      :description => 'Carrots'},
    { :name => 'Cabbage',
      :description => 'Cabbages'},
  ]
)

vegetable.save

preserves = TopLevelCategory.new(
  :name => 'Preserves',
  :description => 'Canned Stuff'
)


preserves.second_level_categories.build([
    { :name => 'Strawberry Jam',
      :description => 'Good stuff made out of strawberries'},
    { :name => 'Pickles',
      :description => 'Homemade Pickes'},
  ]
)

preserves.save
