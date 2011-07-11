module GroupedPage

  def self.included(base)
    base.class_eval {
      has_groups
      has_one :homegroup, :foreign_key => 'homepage_id', :class_name => 'Group'
      include InstanceMethods
      alias_method_chain :permitted_groups, :inheritance
    }
  end
  
  module InstanceMethods
    
    attr_reader :inherited_groups
    def inherited_groups
      @inherited_groups ||= self.parent ? Group.attached_to(self.ancestors) : []
    end

    def permitted_groups_with_inheritance
      permitted_groups_without_inheritance + inherited_groups
    end

    # this is regrettably expensive
    def cache?
      self.permitted_groups.empty?
    end        

    def has_inherited_group?(group)
      return self.inherited_groups.include?(group)
    end
    
    def group_is_inherited?(group)
      return self.has_inherited_group?(group) && !self.has_group?(group)
    end
    
  end

end


