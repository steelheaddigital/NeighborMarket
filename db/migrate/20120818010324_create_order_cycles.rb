class CreateOrderCycles < ActiveRecord::Migration
  def change
    create_table :order_cycles do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :current

      t.timestamps
    end
  end
end
