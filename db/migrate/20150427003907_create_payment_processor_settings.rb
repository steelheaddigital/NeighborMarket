class CreatePaymentProcessorSettings < ActiveRecord::Migration
  def up
    create_table :payment_processor_settings do |t|
      t.string :processor_type, default: 'InPerson'
    end

    execute <<-SQL
      INSERT INTO payment_processor_settings DEFAULT VALUES;
    SQL
  end

  def down
    drop_table :payment_processor_settings
  end
end
