class AddOrderCycleSettingIdToOrderCycle < ActiveRecord::Migration
  def up
    add_reference :order_cycles, :order_cycle_setting, index: true, default: 1

    execute <<-SQL 
      UPDATE order_cycles
      SET order_cycle_setting_id = 1
    SQL
  end

  def down
    remove_reference :order_cycles, :order_cycle_setting
  end
end
