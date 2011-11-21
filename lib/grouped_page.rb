module GroupedPage

  def self.included(base)
    base.class_eval {
      has_groups
      has_one :homegroup, :foreign_key => 'homepage_id', :class_name => 'Group'
      include InstanceMethods
      alias_method_chain :group_ids, :inheritance
      alias_method_chain :cache?, :restrictions
    }
  end
  
  module InstanceMethods
    
    attr_reader :inherited_groups
    def inherited_groups
      @inherited_groups ||= self.parent ? Group.attached_to(self.ancestors) : []
    end
    
    # If a grandparent page is associated with a supergroup page
    # then all of the descendant pages are bound to all of the descendant groups.
    def inherited_group_ids
      self.ancestors.map(&:group_ids).flatten.uniq
    end

    def group_ids_with_inheritance
      (group_ids_without_inheritance + inherited_group_ids).flatten.uniq
    end

    # this is regrettably expensive and I plan to replace it with a 
    # private? setter that would be cascaded on page update
    #
    def restricted?
      self.groups.any?
    end
    
    def cache_with_restrictions?
      cache_without_restrictions? && !restricted?
    end

    def has_inherited_group?(group)
      return self.inherited_groups.include?(group)
    end
    
    def group_is_inherited?(group)
      return self.has_inherited_group?(group) && !self.has_group?(group)
    end
    
  end

end


