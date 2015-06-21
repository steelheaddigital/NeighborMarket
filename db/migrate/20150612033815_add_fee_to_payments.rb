class AddFeeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :fee, :decimal
  end
end
