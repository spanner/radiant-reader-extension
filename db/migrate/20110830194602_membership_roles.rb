class MembershipRoles < ActiveRecord::Migration
  def self.up
    add_column :memberships, :role, :string
    add_column :groups, :leader_id, :integer
  end

  def self.down
    remove_column :memberships, :role
    remove_column :groups, :leader_id
  end
end
