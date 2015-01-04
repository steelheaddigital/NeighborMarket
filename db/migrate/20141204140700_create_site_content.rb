class CreateSiteContent < ActiveRecord::Migration
  def up
    create_table :site_contents do |t|
      t.text    :site_description
      t.text    :inventory_guidelines
      t.text    :terms_of_service
      t.boolean :require_terms_of_service, default: true
    end
    
    execute <<-SQL 
      INSERT INTO site_contents(site_description, inventory_guidelines, terms_of_service, require_terms_of_service)
      SELECT site_description, inventory_guidelines, terms_of_service, require_terms_of_service
      FROM site_settings
      LIMIT 1
    SQL
    
    remove_column :site_settings, :site_description
    remove_column :site_settings, :inventory_guidelines
    remove_column :site_settings, :terms_of_service
    remove_column :site_settings, :require_terms_of_service
  end
  
  def down
    add_column :site_settings, :site_description, :text
    add_column :site_settings, :inventory_guidelines, :text
    add_column :site_settings, :terms_of_service, :text
    add_column :site_settings, :require_terms_of_service, :boolean, default: true
    
    execute <<-SQL 
      UPDATE site_settings
      SET site_description = (SELECT site_description FROM site_contents LIMIT 1),
          inventory_guidelines = (SELECT inventory_guidelines FROM site_contents LIMIT 1),
          terms_of_service = (SELECT terms_of_service FROM site_contents LIMIT 1),
          require_terms_of_service = (SELECT require_terms_of_service FROM site_contents LIMIT 1)
      WHERE id = (SELECT id FROM site_settings LIMIT 1)
    SQL
    
    drop_table :site_contents
  end
end
