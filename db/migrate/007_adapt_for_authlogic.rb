class AdaptForAuthlogic < ActiveRecord::Migration
  def self.up
    add_column :readers, :persistence_token, :string, :null => false, :default => ""
    add_column :readers, :single_access_token, :string, :null => false, :default => ""
    add_column :readers, :perishable_token, :string, :null => false, :default => ""
    add_column :readers, :login_count, :integer, :null => false, :default => 0
    add_column :readers, :failed_login_count, :integer, :null => false, :default => 0
    add_column :readers, :current_login_ip, :string
    add_column :readers, :last_login_ip, :string
    add_column :readers, :clear_password, :string

    change_column :readers, :password, :string, :limit => 255
    change_column :readers, :salt, :string, :limit => 255

    rename_column :readers, :password, :crypted_password
    rename_column :readers, :salt, :password_salt
    rename_column :readers, :last_seen, :last_request_at
    rename_column :readers, :last_login, :last_login_at
    
    remove_column :readers, :activation_code
    remove_column :readers, :previous_login    
  end
  
  def self.down

  end
end
