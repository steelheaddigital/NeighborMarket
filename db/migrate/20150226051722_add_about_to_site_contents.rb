class AddAboutToSiteContents < ActiveRecord::Migration
  def change
    add_column :site_contents, :about, :text
  end
end
