class AddGoogleAnalyticsToSiteSettings < ActiveRecord::Migration
  def change
    add_column :site_settings, :google_analytics_enabled, :boolean, :default => false
    add_column :site_settings, :google_analytics_app_id, :text
  end
end
