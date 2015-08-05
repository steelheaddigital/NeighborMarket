class RemoveInitialFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :initial
  end
end
