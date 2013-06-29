class AddModesToSiteSettings < ActiveRecord::Migration
  def change
    add_column :site_settings, :drop_point, :boolean, :default => true
    add_column :site_settings, :delivery, :boolean, :default => false
  end
end
