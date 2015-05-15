class AddProcessorTypeAndTransactionTypeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :processor_type, :string
    add_column :payments, :payment_type, :string
  end
end
