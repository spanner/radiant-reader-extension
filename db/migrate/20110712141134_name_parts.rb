class NameParts < ActiveRecord::Migration
  def self.up
    add_column :readers, :surname, :string
  end

  def self.down
    remove_column :readers, :surname, :string
  end
end
