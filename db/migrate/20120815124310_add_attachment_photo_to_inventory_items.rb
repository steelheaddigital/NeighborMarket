class AddAttachmentPhotoToInventoryItems < ActiveRecord::Migration
  def self.up
    change_table :inventory_items do |t|
      t.has_attached_file :photo
    end
  end

  def self.down
    drop_attached_file :inventory_items, :photo
  end
end
