class DropDomainFromSiteSettings < ActiveRecord::Migration
  def change
    remove_column :site_settings, :domain
  end
end
