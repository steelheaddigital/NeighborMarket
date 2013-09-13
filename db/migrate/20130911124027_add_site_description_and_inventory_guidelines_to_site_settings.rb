class AddSiteDescriptionAndInventoryGuidelinesToSiteSettings < ActiveRecord::Migration
  def change
    add_column :site_settings, :site_description, :text
    add_column :site_settings, :inventory_guidelines, :text
  end
end
