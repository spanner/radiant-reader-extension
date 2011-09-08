class MembershipAttributes < ActiveRecord::Migration
  def self.up
    add_column :memberships, :role, :string
    add_column :memberships, :admin, :boolean
  end

  def self.down
    remove_column :memberships, :role
    remove_column :memberships, :admin
  end
end
