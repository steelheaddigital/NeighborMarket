# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

site_settings = SiteSetting.instance.update(
  :site_name => "Neighbor Market",
  :time_zone => "Pacific Time (US & Canada)"
)

User.delete_all
user = User.new(
  :username => "manager",
  :email => "email@somesite.com",
  :password   => "Abc123!", 
)
user.add_role('manager')

user.skip_confirmation!
user.save(:validate => false)

fresh_produce = TopLevelCategory.new(
  :name => 'Fresh Produce',
  :description => 'Fresh Produce'
)
fresh_produce.second_level_categories.build([
    { :name => 'Roots',
      :description => 'Roots'},
    { :name => 'Greens',
      :description => 'Greens'},
    { :name => 'Fruits',
      :description => 'Fruits'},
    { :name => 'Squash',
      :description => 'Squash'},
    { :name => 'Herbs',
      :description => 'Herbs'},
    { :name => 'Other Fresh Produce',
      :description => 'Other Fresh Produce'}
  ]
)
fresh_produce.save

animal_products = TopLevelCategory.new(
  :name => 'Animal Products',
  :description => 'Animal Products'
)
animal_products.second_level_categories.build([
    { :name => 'Meat',
      :description => 'Meat'},
    { :name => 'Dairy',
      :description => 'Dairy'},
    { :name => 'Eggs',
      :description => 'Eggs'}
  ]
)
animal_products.save

prepared_food = TopLevelCategory.new(
  :name => 'Prepared Food',
  :description => 'Prepared Food'
)
prepared_food.second_level_categories.build([
    { :name => 'Baked Goods',
      :description => 'Baked Goods'},
    { :name => 'Soup',
      :description => 'Soup'},
    { :name => 'Meals',
      :description => 'Meals'},
    { :name => 'Snacks',
      :description => 'Snacks'},
    { :name => 'Drinks',
      :description => 'Drinks'},
    { :name => 'Other Prepared Food',
      :description => 'Other Prepared Food'},
    { :name => 'Condiments',
      :description => 'Condiments'}
  ]
)
prepared_food.save

preserved_food = TopLevelCategory.new(
  :name => 'Preserved Food',
  :description => 'Preserved Food'
)
preserved_food.second_level_categories.build([
    { :name => 'Pickles',
      :description => 'Pickles'},
    { :name => 'Jams, Jellies, and Fruit Preserves',
      :description => 'Jams, Jellies, and Preserves'},
    { :name => 'Canned Fruits and Vegetables',
      :description => 'Canned Fruits and Vegetables'},
    { :name => 'Dried Food',
      :description => 'Dried Food'},
    { :name => 'Other Preserved Food',
      :description => 'Other Preserved Food'}
  ]
)
preserved_food.save

household_goods = TopLevelCategory.new(
  :name => 'Household Goods',
  :description => 'Household Goods'
)
household_goods.second_level_categories.build([
    { :name => 'Cleaning Supplies',
      :description => 'Cleaning Supplies'},
    { :name => 'Personal Care Products',
      :description => 'Personal Care'},
    { :name => 'Other Household Goods',
      :description => 'Other Household Goods'}
  ]
)
household_goods.save

durable_goods = TopLevelCategory.new(
  :name => 'Durable Crafts',
  :description => 'Durable Crafts'
)
durable_goods.second_level_categories.build([
    { :name => 'Ceramics',
      :description => 'Ceramics'},
    { :name => 'Wood Products',
      :description => 'Wood Products'},
    { :name => 'Textiles',
      :description => 'Textiles'},
    { :name => 'Metal Products',
      :description => 'Metal Products'},
    { :name => 'Fine Art',
      :description => 'Fine Art'},
    { :name => 'Other Durable Crafts',
      :description => 'Other Durable Crafts'}   
  ]
)
durable_goods.save

PriceUnit.create(:name => "each")
PriceUnit.create(:name => "ounce")
PriceUnit.create(:name => "pound")
PriceUnit.create(:name => "quart")
PriceUnit.create(:name => "gallon")
PriceUnit.create(:name => "jar")
