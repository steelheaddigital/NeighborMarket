class AddApprovedToSeller < ActiveRecord::Migration
  def change
    add_column :sellers, :approved, :boolean, :default => false, :null => false
    add_index :sellers, :approved
  end
end
