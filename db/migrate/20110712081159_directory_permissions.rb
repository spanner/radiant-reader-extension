class DirectoryPermissions < ActiveRecord::Migration
  def self.up
    add_column :readers, :unshareable, :boolean
    add_column :readers, :unshared, :text
  end

  def self.down
    remove_column :readers, :unshareable
    remove_column :readers, :unshared
  end
end
