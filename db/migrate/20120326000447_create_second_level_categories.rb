class CreateSecondLevelCategories < ActiveRecord::Migration
  def change
    create_table :second_level_categories do |t|
      t.integer :top_level_category_id
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
