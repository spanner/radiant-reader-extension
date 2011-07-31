class Message < ActiveRecord::Base

  has_site if respond_to? :has_site

  belongs_to :layout
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :group

  has_many :deliveries, :class_name => 'MessageReader', :conditions => ["message_readers.sent_at IS NOT NULL and message_readers.sent_at <= ?", Time.now.to_s(:db)]
  has_many :recipients, :through => :deliveries, :source => :reader

  validates_presence_of :subject
  validates_presence_of :body

  object_id_attr :filter, TextFilter

  default_scope :order => 'updated_at DESC, created_at DESC'
  named_scope :for_function, lambda { |f| {:conditions => ["function_id = ?", f.to_s]} }
  named_scope :administrative, { :conditions => "function_id IS NOT NULL AND NOT function_id = ''" }
  named_scope :ordinary, { :conditions => "function_id = '' OR function_id IS NULL" }
  named_scope :published, { :conditions => "status_id >= 100" }

  named_scope :belonging_to, lambda {|group|
   { :conditions => {:group_id => group }}
  }

  named_scope :ungrouped, :conditions => {:group_id => nil}

  def filtered_body
    filter.filter(body)
  end

  # has to return a named_scope for chainability
  def possible_readers
    groups.any? ? Reader.in_groups(groups) : Reader.scoped({})
  end

  def undelivered_readers
    if recipients.any?
      possible_readers.except(recipients)
    else
      recipients
    end
  end

  def inactive_readers
    possible_readers.inactive
  end

  def active_readers
    possible_readers.active
  end

  def delivered?
    deliveries.any?
  end

  def preview(reader=nil)
    reader ||= possible_readers.first || Reader.for_user(created_by)
    ReaderNotifier.create_message(reader, self)
  end
  
  def function
    MessageFunction[self.function_id]
  end
  def self.functional(function, group=nil)
    messages = for_function(function)
    if group
      messages.belonging_to(group).first
    else
      messages.ungrouped.first
    end
  end
  def has_function?
    !function.nil?
  end
  def administrative?
    has_function?
  end

  def status
    Status.find(self.status_id)
  end
  def status=(value)
    self.status_id = value.id
  end
  def published?
    status == Status[:published]
  end
  def published!
    status = Status[:published]
  end

  def deliver(readers)
    failures = []
    readers.each do |reader|
      failures.push(reader) unless deliver_to(reader)
    end
    self.published!
    failures
  end

  def deliver_to(reader, sender=nil)
    ReaderNotifier.deliver_message(reader, self, sender)
    record_delivery(reader)
    true
  rescue => e
    logger.warn "@@  delivery failed: #{e.inspect}"
    raise
  end

  def record_delivery(reader)
    MessageReader.find_or_create_by_message_id_and_reader_id(self.id, reader.id).update_attribute(:sent_at, Time.now)
  end

  def delivered_to?(reader)
    recipients.include?(reader)
  end
  
  def delivery_to(reader)
    deliveries.to_reader(reader).first if delivered_to?(reader)
  end
end
