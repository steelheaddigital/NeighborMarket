class CreateTopLevelCategories < ActiveRecord::Migration
  def change
    create_table :top_level_categories do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
