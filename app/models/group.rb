class Group < ActiveRecord::Base

  has_site if respond_to? :has_site
  default_scope :order => 'name'

  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  belongs_to :homepage, :class_name => 'Page'

  has_many :messages
  has_many :permissions
  has_many :pages, :through => :permissions
  has_many :memberships
  has_many :readers, :through => :memberships, :uniq => true
  
  before_validation :set_slug
  validates_presence_of :name, :slug, :allow_blank => false
  validates_uniqueness_of :name, :slug
  
  named_scope :with_home_page, { :conditions => "homepage_id IS NOT NULL", :include => :homepage }
  named_scope :subscribable, { :conditions => "public = 1" }
  named_scope :unsubscribable, { :conditions => "public = 0" }

  named_scope :from_list, lambda { |ids|
    { :conditions => ["groups.id IN (#{ids.map{"?"}.join(',')})", *ids] }
  }

  named_scope :containing, lambda { |reader|
    {
      :joins => "INNER JOIN memberships as mb on mb.group_id = groups.id", 
      :conditions => ["mb.reader_id = ?", reader.id],
      :group => column_names.map { |n| 'groups.' + n }.join(',')
    }
  }

  named_scope :attached_to, lambda { |objects|
    conditions = objects.map{|o| "(pp.permitted_type = ? AND pp.permitted_id = ?)" }.join(" OR ")
    binds = objects.map{|o| [o.class.to_s, o.id]}.flatten
    {
      :select => "groups.*, count(pp.group_id) AS pcount",
      :joins => "INNER JOIN permissions as pp on pp.group_id = groups.id", 
      :conditions => [conditions, *binds],
      :having => "pcount > 0",    # otherwise attached_to([]) returns all groups
      :group => column_names.map { |n| 'groups.' + n }.join(','),
      :readonly => false
    }
  }

  def self.visible_to(reader=nil)
    return all if Radiant.config['readers.public?']
    return scoped({:conditions => "1 = 0"}) unless reader   # nasty but chainable
    return containing(reader) if Radiant.config['readers.confine_to_groups?']
    return all
  end
  
  def visible_to?(reader=nil)
    self.class.visible_to(reader).include? self
  end

  def url
    homepage.url if homepage
  end
  
  def filename
    name.downcase.gsub(/\W/, '_')
  end
  
  def send_welcome_to(reader)
    if reader.activated?                                                             # welcomes are also triggered on activation
      if message = Message.belonging_to(self).for_function('group_welcome').first    # only if a group_welcome message exists *belonging to this group*
        message.deliver_to(reader)
      end
    end
  end

  def admit(reader)
    self.readers << reader
  end

  def permission_for(object)
    self.permissions.for(object).first
  end

  def membership_for(reader)
    self.memberships.for(reader).first
  end
  
  # we can't has_many through the polymorphic permission relationship, so this is called from has_groups
  # and for eg. Page, it defines:
  # Permission.for_pages named_scope
  # Group.page_permissions  => set of permission objects
  # Group.pages             => set of page objects
  
  def self.define_retrieval_methods(classname)
    type_scope = "for_#{classname.downcase.pluralize}".intern
    Permission.send :named_scope, type_scope, :conditions => { :permitted_type => classname }
    define_method("#{classname.downcase}_permissions") { self.permissions.send type_scope }
    define_method("#{classname.downcase.pluralize}") { self.send("#{classname.to_s.downcase}_permissions".intern).map(&:permitted) }
  end
  
private

  def set_slug
    self.slug ||= self.name.slugify.to_s
  end

end

