class MessageFunctions < ActiveRecord::Migration
  def self.up
    rename_column :messages, :function, :function_id
  end

  def self.down
    rename_column :messages, :function_id, :function
  end
end
