class AddAutoCreateFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auto_created, :boolean, :default => false
    add_column :users, :auto_create_updated_at, :datetime
  end
end
