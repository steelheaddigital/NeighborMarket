class CreateSiteSettings < ActiveRecord::Migration
  def change
    create_table :site_settings do |t|
      t.string :domain
      t.string :site_name
      t.string :drop_point_address
      t.string :drop_point_city
      t.string :drop_point_state
      t.integer :drop_point_zip
    end
  end
end
