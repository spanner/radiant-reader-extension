class Subgroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :parent_id, :integer
  end

  def self.down
    remove_column :groups, :parent_id
  end
end
