class AddRefundedPaymentIdToPayments < ActiveRecord::Migration
  def change
    add_reference :payments, :refunded_payment, index: true
  end
end
