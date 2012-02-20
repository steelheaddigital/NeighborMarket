class CreateManagers < ActiveRecord::Migration
  def change
    create_table :managers do |t|
      t.references :user
    end
  end
end
