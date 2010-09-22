class LockVersions < ActiveRecord::Migration
  def self.up
    add_column :readers, :lock_version, :integer, :default => 0
  end

  def self.down
    remove_column :readers, :lock_version
  end
end
