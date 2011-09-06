class GroupAncestry < ActiveRecord::Migration
  def self.up
    remove_column :groups, :root_group_id
    remove_column :groups, :lft
    remove_column :groups, :rgt
    add_column :groups, :ancestry, :string
    add_index :groups, :ancestry
    
    Group.reset_column_information
    Group.build_ancestry_from_parent_ids!
    
    remove_column :groups, :parent_id
  end

  def self.down
    remove_column :groups, :ancestry
    remove_index :groups, :ancestry
    add_column :groups, :parent_id
    add_column :groups, :root_group_id, :integer
    add_column :groups, :lft, :integer
    add_column :groups, :rgt, :integer
  end
end
