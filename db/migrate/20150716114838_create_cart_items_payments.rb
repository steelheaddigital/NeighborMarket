class CreateCartItemsPayments < ActiveRecord::Migration
  def change
    create_table :cart_items_payments do |t|
      t.belongs_to :payment, index: true
      t.belongs_to :cart_item, index: true
    end
  end
end
