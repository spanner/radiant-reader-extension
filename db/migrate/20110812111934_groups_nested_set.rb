class GroupsNestedSet < ActiveRecord::Migration
  def self.up
    add_column :groups, :parent_id, :integer
    add_column :groups, :root_group_id, :integer
    add_column :groups, :lft, :integer
    add_column :groups, :rgt, :integer
    
    Group.reset_column_information
    Group.rebuild!
    Group.all.each {|g| g.save }
  end

  def self.down
    remove_column :groups, :parent_id
    remove_column :groups, :root_group_id
    remove_column :groups, :lft
    remove_column :groups, :rgt
  end
end
