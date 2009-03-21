class UserReaders < ActiveRecord::Migration

  def self.up
    add_column :readers, :user_id, :integer
  end

  def self.down
    remove_column :readers, :user_id
  end
  
end
