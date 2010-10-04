class UnlockVersion < ActiveRecord::Migration
  def self.up
    remove_column :readers, :lock_version
  end

  def self.down
    add_column :readers, :lock_version, :integer, :default => 0
  end
end
