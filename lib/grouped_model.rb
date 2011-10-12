module GroupedModel
  
  # Grouped Models are those that can be assigned to one or more groups, and so made invisible to any reader 
  # who is not a member of one of those groups. As standard this is applied to pages and messages.
  # To group-limit another class:
  #
  # class Widget < ActiveRecord::Base
  #   has_groups
  #   ...
  #
  # This will define several class and instance methods and some scopes, most usefully:
  #
  # Widget#groups               -> groups association can << and +/- in the usual ways
  # Group#widgets               -> a scope, not an association
  # Widget#visible_to?(reader)  -> boolean
  # Widget.visible_to(reader)   -> list of visible widgets (as scope)
  # Widget.belonging_to(group)  -> list of widgets
  #
  # The situation is more complex than it seems because of polymorphy and group-inheritance but that should all be taken care of for you.
  #
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Returns true if group relations have been established in this model.
    def has_groups?
      false
    end
    alias :has_group? :has_groups?
    
    # Sets up group relations and scopes in this model. No extra columns are required in the model table.
    #
    def has_groups(options={})
      return if has_groups?
      
      class_eval {
        include GroupedModel::GroupedInstanceMethods

        def self.has_groups?
          true
        end
        
        def self.visible
          ungrouped
        end
      }
      
      has_many :permissions, :as => :permitted
      accepts_nested_attributes_for :permissions
      has_many :groups, :through => :permissions
      Group.define_retrieval_methods(self.to_s)

      named_scope :visible_to, lambda { |reader| 
        conditions = "pp.group_id IS NULL"
        if reader && reader.is_grouped?
          ids = reader.all_group_ids
          conditions = ["#{conditions} OR pp.group_id IS NULL OR pp.group_id IN(#{ids.map{"?"}.join(',')})", *ids]
        end
        {
          :joins => "LEFT OUTER JOIN permissions as pp on pp.permitted_id = #{self.table_name}.id AND pp.permitted_type = '#{self.to_s}'",
          :group => column_names.map { |n| self.table_name + '.' + n }.join(','),
          :conditions => conditions,
          :readonly => false
        } 
      }

      named_scope :ungrouped, lambda {
        {
          :select => "#{self.table_name}.*, count(pp.id) as group_count",
          :joins => "LEFT OUTER JOIN permissions as pp on pp.permitted_id = #{self.table_name}.id AND pp.permitted_type = '#{self.to_s}'", 
          :having => "group_count = 0",
          :group => column_names.map { |n| self.table_name + '.' + n }.join(','),    # postgres requires that we group by all selected (but not aggregated) columns
          :readonly => false
        }
      } do
        def count
          length
        end
      end

      named_scope :grouped, lambda {
          {
          :select => "#{self.table_name}.*, count(pp.id) as group_count",
          :joins => "LEFT OUTER JOIN permissions as pp on pp.permitted_id = #{self.table_name}.id AND pp.permitted_type = '#{self.to_s}'", 
          :having => "group_count > 0",
          :group => column_names.map { |n| self.table_name + '.' + n }.join(','),
          :readonly => false
        }
      } do
        def count
          length
        end
      end
      
      named_scope :belonging_to, lambda { |group|
        group_ids = group.subtree_ids
        {
          :joins => "INNER JOIN permissions as pp on pp.permitted_id = #{self.table_name}.id AND pp.permitted_type = '#{self.to_s}'", 
          :group => column_names.map { |n| self.table_name + '.' + n }.join(','),
          :conditions => ["pp.group_id IN (#{group_ids.map{"?"}.join(',')})", *group_ids],
          :readonly => false
        }
      }
      
      named_scope :find_these, lambda { |ids|
        ids = ['NULL'] unless ids && ids.any?
        { :conditions => ["#{self.table_name}.id IN (#{ids.map{"?"}.join(',')})", *ids] }
      }
            
    end
    alias :has_group :has_groups
  end

  module GroupedInstanceMethods

    # The list of groups that is allowed to see this object. This will include the groups directly
    # associated and their descendant subgroups.
    #
    def permitted_groups
      if permitted_group_ids.any?
        Group.find(permitted_group_ids)
      else
        []
      end
    end

    def permitted_group_ids
      # in GroupedPage this is chained to include groups inherited from ancestor pages
      # while here the subtrees provide inheritance from ancestor groups.
      #
      groups.map(&:subtree_ids).flatten.uniq
    end

    def visible_to?(reader)
      return true if self.permitted_groups.empty?
      return false if reader.nil?
      return true if reader.is_admin?
      return (reader.groups & self.permitted_groups).any?
    end

    def group
      if self.permitted_groups.length == 1
        self.permitted_groups.first
      else
        nil
      end
    end
    
    def visible?
      permitted_groups.empty?
    end

    def permitted_readers
      permitted_groups.any? ? Reader.in_groups(permitted_groups) : Reader.scoped({})
    end
    
    def has_group?(group)
      return self.permitted_groups.include?(group)
    end
    
    def permit(group)
      self.groups << group unless self.has_group?(group)
    end

    def group_id_list
      self.groups.map(&:id).join(',')
    end

    def group_id_list=(ids)
      self.groups = Group.find_these(ids.split(/,\s*/))
    end
  end
end
