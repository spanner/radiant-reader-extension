class SortOutNames < ActiveRecord::Migration
  def self.up
    add_column :readers, :nickname, :string
    Reader.all.each do |r|
      r.send :combine_names
      r.save if r.changed?
    end
  end

  def self.down
    remove_column :readers, :nickname
  end
end
