# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

env = Rails.env
app_config = YAML::load(File.open("config/main_conf.yml"))
manager_email = app_config["#{env}"]['manager_email']

User.delete_all
user = User.new(
  :email => manager_email
)
user.add_role('manager')
user.auto_create_user

site_settings = SiteSetting.new(:site_name => 'Neighbor Market')
site_settings.save

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
