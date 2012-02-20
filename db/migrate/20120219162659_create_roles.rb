class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.references :user
      t.integer :rolable_id
      t.string :rolable_type
    end
  end
end
