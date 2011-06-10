class MultipleOwnership < ActiveRecord::Migration
  def self.up
    rename_column :permissions, :page_id, :permitted_id
    add_column :permissions, :permitted_type, :string
    Permission.reset_column_information
    Permission.all.each {|p| p.update_attributes(:permitted_type => 'Page') }
  end

  def self.down
    rename_column :permissions, :permitted_id, :page_id
    remove_column :permissions, :permitted_type
  end
end
