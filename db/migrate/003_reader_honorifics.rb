class ReaderHonorifics < ActiveRecord::Migration

  def self.up
    add_column :readers, :honorific, :string
    Radiant::Config['reader.use_honorifics?'] = false
  end

  def self.down
    remove_column :readers, :honorific
  end
  
end
