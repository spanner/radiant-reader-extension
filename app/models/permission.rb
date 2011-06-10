class Permission < ActiveRecord::Base

  belongs_to :group
  belongs_to :permitted, :polymorphic => true
  
  named_scope :for, lambda { |object|
    { :conditions => ["permissions.permitted_id = ? and permissions.permitted_type = ?", object.id, object.class.to_s] }
  }
  
end

