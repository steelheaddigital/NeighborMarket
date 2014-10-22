class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
        t.integer :rating
    	  t.text :review
      	t.references :reviewable, polymorphic: true
      	t.references :user
      	t.timestamps
    end
    add_index :reviews, [:reviewable_id, :reviewable_type]
    add_index :reviews, :user_id
  end
end
