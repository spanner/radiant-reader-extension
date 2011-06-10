class Membership < ActiveRecord::Base

  belongs_to :group
  belongs_to :reader
  
  named_scope :for, lambda { |reader|
    {
      :conditions => ["memberships.reader_id = ?", reader.id]
    }
  }
  
end

