class AddDirectionsToSiteSettings < ActiveRecord::Migration
  def change
    add_column :site_settings, :directions, :text
  end
end
