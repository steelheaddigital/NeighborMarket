class AddPaddingToOrderCycleSettings < ActiveRecord::Migration
  def change
    add_column :order_cycle_settings, :padding, :integer
    add_column :order_cycle_settings, :padding_interval, :string
  end
end
