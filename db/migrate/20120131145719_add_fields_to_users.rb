class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :initial, :string
    add_column :users, :phone, :string
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :country, :string
    add_column :users, :zip, :string
    add_column :users, :aboutme, :text
    add_column :users, :delivery_instructions, :text
    add_column :users, :payment_instructions, :text
    add_column :users, :approved_seller, :boolean, :default => false, :null => false
    add_column :users, :listing_approval_style, :string, :default => "manual", :null => false
  end
end
