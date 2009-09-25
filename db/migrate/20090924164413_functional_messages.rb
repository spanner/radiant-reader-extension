class FunctionalMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :function, :string
  end

  def self.down
    remove_column :messages, :function
  end
end
