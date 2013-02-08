class CreatePriceUnits < ActiveRecord::Migration
  def change
    create_table :price_units do |t|
      t.string :name

      t.timestamps
    end
  end
end
