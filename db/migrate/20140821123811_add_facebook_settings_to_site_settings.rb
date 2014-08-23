class AddFacebookSettingsToSiteSettings < ActiveRecord::Migration
  def change
    add_column :site_settings, :facebook_enabled, :boolean, :default => false
    add_column :site_settings, :facebook_app_id, :text
  end
end
