class Membership < ActiveRecord::Base

  belongs_to :group
  belongs_to :reader
  
  named_scope :for, lambda { |reader|
    { :conditions => ["memberships.reader_id = ?", reader.id] }
  }

  named_scope :of, lambda { |group|
    { :conditions => ["memberships.group_id = ?", group.id] }
  }
  
end
