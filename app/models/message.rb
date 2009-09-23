class Message < ActiveRecord::Base

  is_site_scoped if defined? ActiveRecord::SiteNotFound
  default_scope :order => 'created_at DESC'

  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  has_many :message_readers
  has_many :readers, :through => :message_readers

  has_many :deliveries, :class_name => 'MessageReader', :conditions => "message_readers.sent_at IS NOT NULL and message_readers.sent_at <= NOW()"
  has_many :recipients, :through => :deliveries, :source => :reader

  validates_presence_of :subject
  validates_presence_of :body

  object_id_attr :filter, TextFilter
  
  def filtered_body
    filter.filter(body)
  end
  
  def possible_readers
    Reader.find(:all)
  end
  
  def undelivered_readers
    readers - recipients
  end
  
  def delivered?
    deliveries.any?
  end
  
  def delivered_to?(reader)
    recipients.include?(reader)
  end
    
  def preview
    reader = possible_readers.first || Reader.find_or_create_for_user(created_by)
    ReaderNotifier.create_message(reader, self)
  end
  
  def deliver
    undelivered_readers.each { |reader| deliver_to(reader) }
  end

  def deliver_all
    readers.each { |reader| deliver_to(reader) }
  end

  def deliver_to(reader)
    ReaderNotifier.deliver_message(reader, self)
    record_delivery(reader)
  end
  
  def record_delivery(reader)
    MessageReader.find_or_create_by_message_id_and_reader_id(self.id, reader.id).update_attribute(:sent_at, Time.now)
  end
end
