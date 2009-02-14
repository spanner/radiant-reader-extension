class ExtendSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :reader_layout_id, :integer if defined? MultiSiteExtension
  end

  def self.down
    remove_column :sites, :reader_layout_id
  end
end
