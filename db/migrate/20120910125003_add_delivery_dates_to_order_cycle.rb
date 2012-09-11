class AddDeliveryDatesToOrderCycle < ActiveRecord::Migration
  def change
    add_column :order_cycles, :seller_delivery_date, :datetime
    add_column :order_cycles, :buyer_pickup_date, :datetime
  end
end
