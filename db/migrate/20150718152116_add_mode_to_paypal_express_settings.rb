class AddModeToPaypalExpressSettings < ActiveRecord::Migration
  def change
    add_column :paypal_express_settings, :mode, :string, default: 'Test'
  end
end
