class ExtendSites < ActiveRecord::Migration
  def self.up
    if defined? MultiSiteExtension
      add_column :sites, :reader_layout_id, :integer
    end
  end

  def self.down
    remove_column :sites, :reader_layout_id
  end
end
