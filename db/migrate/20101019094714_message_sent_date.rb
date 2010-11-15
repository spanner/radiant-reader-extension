class MessageSentDate < ActiveRecord::Migration
  def self.up
    add_column :messages, :sent_at, :datetime
    Message.reset_column_information
    Message.all.each { |message| message.sent_at = message.updated_at || message.created_at; message.save! }
  end

  def self.down
    remove_column :messages, :sent_at
  end
end
