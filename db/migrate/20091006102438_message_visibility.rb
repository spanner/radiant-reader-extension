class MessageVisibility < ActiveRecord::Migration
  def self.up
    add_column :messages, :status_id, :integer, :default => 1
  end

  def self.down
    remove_column :messages, :status_id
  end
end
