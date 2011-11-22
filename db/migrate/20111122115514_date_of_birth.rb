class DateOfBirth < ActiveRecord::Migration
  def self.up
    add_column :readers, :dob, :date
    add_column :readers, :dob_secret, :boolean
  end

  def self.down
    remove_column :readers, :dob
    remove_column :readers, :dob_secret
  end
end
