class CreateReaders < ActiveRecord::Migration
  def self.up
    create_table :readers, :force => true do |t|
      t.column :site_id, :integer
      t.column :name, :string, :limit => 100
      t.column :email, :string
      t.column :login, :string, :limit => 40, :default => "", :null => false
      t.column :password, :string, :limit => 40
      t.column :description, :text
      t.column :notes, :text
      t.column :trusted, :boolean, :default => true
      t.column :receive_email, :boolean, :default => false
      t.column :receive_essential_email, :boolean, :default => true
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :created_by_id, :integer
      t.column :updated_by_id, :integer
      t.column :salt, :string
      t.column :session_token, :string
      t.column :activation_code, :string
      t.column :provisional_password, :string
      t.column :activated_at, :datetime
      # t.column :lock_version, :integer, :default => 0
    end
    add_index :readers, ["session_token"], :name => "session_token"
  end

  def self.down
    drop_table :readers
  end
end
