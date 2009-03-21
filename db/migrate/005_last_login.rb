class LastLogin < ActiveRecord::Migration

  def self.up
    add_column :readers, :last_seen, :datetime
    add_column :readers, :last_login, :datetime
    add_column :readers, :previous_login, :datetime
  end

  def self.down
    remove_column :readers, :last_seen
    remove_column :readers, :last_login
    remove_column :readers, :previous_login
  end
  
end
