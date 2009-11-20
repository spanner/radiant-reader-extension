class MessagesHaveLayout < ActiveRecord::Migration
  def self.up
    add_column :messages, :layout_id, :integer
  end

  def self.down
    remove_column :messages, :layout_id
  end
end
