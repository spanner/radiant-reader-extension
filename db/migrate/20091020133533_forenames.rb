class Forenames < ActiveRecord::Migration
  def self.up
    add_column :readers, :forename, :string
  end

  def self.down
    remove_column :readers, :forename
  end
end
