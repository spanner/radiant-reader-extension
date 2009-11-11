class EnsureFunctionalMessagesVisible < ActiveRecord::Migration
  def self.up
    Message.reset_column_information
    Message.administrative.each {|m| m.update_attribute(:status_id, 100)}
  end

  def self.down
  end
end
