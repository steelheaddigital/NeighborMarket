class AddReputationSettingsToSiteSettings < ActiveRecord::Migration
  def change
    add_column :site_settings, :reputation_enabled, :boolean, :default => false
  end
end
