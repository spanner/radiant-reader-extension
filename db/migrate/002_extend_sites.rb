class ExtendSites < ActiveRecord::Migration
  def self.up
    if defined? Site
      add_column :sites, :reader_layout_id, :integer
      add_column :sites, :mail_from_name, :string
      add_column :sites, :mail_from_address, :string
    end
  end

  def self.down
    if defined? Site
      remove_column :sites, :reader_layout_id
      remove_column :sites, :mail_from_name
      remove_column :sites, :mail_from_address
    end
  end
end
