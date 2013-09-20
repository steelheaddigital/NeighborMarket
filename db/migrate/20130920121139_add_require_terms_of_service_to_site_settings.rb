class AddRequireTermsOfServiceToSiteSettings < ActiveRecord::Migration
  def change
    add_column :site_settings, :require_terms_of_service, :boolean, :default => true 
  end
end
