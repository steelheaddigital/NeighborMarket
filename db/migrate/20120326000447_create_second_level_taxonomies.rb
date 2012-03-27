class CreateSecondLevelTaxonomies < ActiveRecord::Migration
  def change
    create_table :second_level_taxonomies do |t|
      t.integer :top_level_taxonomy_id
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
