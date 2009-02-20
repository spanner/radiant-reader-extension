class ExtendSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :reader_layout_id, :integer
    add_column :sites, :mail_from_name, :string
    add_column :sites, :mail_from_address, :string
  end

  def self.down
    remove_column :sites, :reader_layout_id
    remove_column :sites, :mail_from_name
    remove_column :sites, :mail_from_address
  end
end
