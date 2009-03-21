module ModelExtensions

  def self.included(base)
    base.class_eval do

      unless methods.include?('is_site_scoped') 
        class << self
          define_method("is_site_scoped") { |*args| logger.warn "Multi_site not installed or not correct version: #{self} is not site-scoped." }
          define_method("is_site_scoped?") { |*args| false }
        end
      end
      
      named_scope :since, lambda {|start| { :conditions => ['created_at > ? or updated_at > ?', start, start] } }
      named_scope :by_user, lambda {|user| { :conditions => ['created_by = ?', user.id] } }

    end
  end  
end
