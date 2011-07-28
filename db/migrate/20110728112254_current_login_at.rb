class CurrentLoginAt < ActiveRecord::Migration
  def self.up
    add_column :readers, :current_login_at, :datetime
  end

  def self.down
    remove_column :readers, :current_login_at
  end
end
