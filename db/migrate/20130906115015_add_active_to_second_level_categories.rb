class AddActiveToSecondLevelCategories < ActiveRecord::Migration
  def change
    add_column :second_level_categories, :active, :boolean, :default => true
  end
end
