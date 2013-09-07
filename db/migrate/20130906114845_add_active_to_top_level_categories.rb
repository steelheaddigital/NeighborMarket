class AddActiveToTopLevelCategories < ActiveRecord::Migration
  def change
    add_column :top_level_categories, :active, :boolean, :default => true
  end
end
