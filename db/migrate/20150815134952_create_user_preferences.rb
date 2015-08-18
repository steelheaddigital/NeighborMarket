class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.references :user, index: true
      t.boolean :seller_new_order_cycle_notification, default: true
      t.boolean :seller_purchase_notification, default: true
      t.boolean :buyer_new_order_cycle_notification, default: true
    end
  end
end
