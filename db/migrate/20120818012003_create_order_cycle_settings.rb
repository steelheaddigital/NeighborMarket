class CreateOrderCycleSettings < ActiveRecord::Migration
  def change
    create_table :order_cycle_settings do |t|
      t.boolean :recurring, :default => false
      t.string :interval
    end
  end
end
