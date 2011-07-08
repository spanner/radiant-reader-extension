class GroupSlugs < ActiveRecord::Migration
  def self.up
    add_column :groups, :slug, :string
  end

  def self.down
    remove_column :groups, :slug
  end
end
