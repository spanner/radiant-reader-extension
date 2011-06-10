class GroupsPublic < ActiveRecord::Migration
  def self.up
    add_column :groups, :public, :boolean
    add_column :groups, :invitation, :text
  end

  def self.down
    remove_column :groups, :public
    remove_column :groups, :invitation
  end
end
