class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
    	t.integer :rating
      	t.references :rateable, polymorphic: true
      	t.references :user
      	t.timestamps
    end
  end
end
