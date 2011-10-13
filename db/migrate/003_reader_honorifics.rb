class ReaderHonorifics < ActiveRecord::Migration

  def self.up
    add_column :readers, :honorific, :string
  end

  def self.down
    remove_column :readers, :honorific
  end
  
end
