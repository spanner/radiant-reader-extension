class RemoveLogin < ActiveRecord::Migration
  def self.up
    Reader.reset_column_information
    Reader.all.each do |r|
      r.nickname ||= r.login
      r.save if r.changed?
    end
    remove_column :readers, :login
  end

  def self.down
    add_column :readers, :login, :string
  end
end
