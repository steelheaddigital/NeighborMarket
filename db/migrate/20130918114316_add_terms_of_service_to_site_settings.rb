class AddTermsOfServiceToSiteSettings < ActiveRecord::Migration
  def change
    add_column :site_settings, :terms_of_service, :text
  end
end
