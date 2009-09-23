class ReaderMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :site_id, :integer
      t.column :subject, :string
      t.column :body, :text
      t.column :filter_id, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :created_by_id, :integer
      t.column :updated_by_id, :integer
      t.column :lock_version, :integer
    end

    create_table :message_readers do |t|
      t.column :site_id, :integer
      t.column :message_id, :integer
      t.column :reader_id, :integer
      t.column :sent_at, :datetime
    end
  end

  def self.down
    drop_table :messages
    drop_table :message_readers
  end
end
