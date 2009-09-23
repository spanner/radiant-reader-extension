class MessageReader < ActiveRecord::Base
  belongs_to :message
  belongs_to :reader
  
  named_scope :undelivered, {
    :conditions => "sent_at IS NULL OR sent_at > NOW()"
  }

  named_scope :delivered, {
    :conditions => "sent_at IS NOT NULL and sent_at <= NOW()"
  }

end
