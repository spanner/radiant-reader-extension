require 'authlogic'
require 'digest/sha1'

class Reader < ActiveRecord::Base
  @@user_columns = [:name, :email, :login, :created_at, :password, :notes]
  cattr_accessor :user_columns
  cattr_accessor :current
  attr_accessor :email_field        # used in blocking spam registrations

  acts_as_authentic do |config|
    config.validations_scope = :site_id if defined? Site
    config.transition_from_restful_authentication = true
    config.validate_email_field = false
    config.validate_login_field = false
    config.validate_password_field = false
  end

  belongs_to :user
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  has_many :message_readers
  has_many :messages, :through => :message_readers
  has_many :memberships
  has_many :groups, :through => :memberships
  accepts_nested_attributes_for :memberships

  before_update :update_user

  validates_presence_of :name, :email
  validates_length_of :name, :maximum => 100, :allow_nil => true
  validates_length_of :password, :minimum => 6, :allow_nil => false, :unless => :existing_reader_keeping_password?
  # validates_format_of :password, :with => /[^A-Za-z]/, :unless => :existing_reader_keeping_password?  # we have to match radiant so that users can log in both ways
  validates_confirmation_of :password, :unless => :existing_reader_keeping_password?
  validates_uniqueness_of :login, :allow_blank => true
  validate :email_must_not_be_in_use

  include RFC822
  validates_format_of :email, :with => RFC822_valid

  default_scope :order => 'name ASC'
  named_scope :any
  named_scope :active, :conditions => "activated_at IS NOT NULL"
  named_scope :inactive, :conditions => "activated_at IS NULL"
  named_scope :imported, :conditions => "old_id IS NOT NULL"
  named_scope :except, lambda { |readers|
    readers = [readers].flatten
    if readers.any?
      { :conditions => ["NOT readers.id IN (#{readers.map{"?"}.join(',')})", readers.map(&:id)] }
    else
      { }
    end
  }

  named_scope :in_groups, lambda { |groups| 
    {
      :select => "readers.*",
      :joins => "INNER JOIN memberships as mm on mm.reader_id = readers.id", 
      :conditions => ["mm.group_id IN (#{groups.map{'?'}.join(',')})", *groups.map{|g| g.is_a?(Group) ? g.id : g}],
      :group => "mm.reader_id"
    }
  }

  def self.find_by_login_or_email(login_or_email)
    reader = find(:first, :conditions => ["login = ? OR email = ?", login_or_email, login_or_email])
  end
  
  def self.for_user(user)
    if user.respond_to?(:site) && site = Page.current_site
      reader = self.find_or_create_by_site_id_and_user_id(site.id, user.id)
    else
      reader = self.find_or_create_by_user_id(user.id)
    end
    if reader.new_record?
      user_columns.each { |att| reader.send("#{att.to_s}=", user.send(att)) }
      reader.crypted_password = user.password
      reader.password_salt = user.salt
      reader.activated_at = reader.created_at
      reader.save(false)
    end
    reader
  end

  def forename
    read_attribute(:forename) || name.split(/\s/).first
  end

  def activate!
    self.activated_at = Time.now.utc
    self.save!
    send_welcome_message
    send_group_welcomes
  end

  def activated?
    !inactive?
  end

  def inactive?
    self.activated_at.nil?
  end

  def disable_perishable_token_maintenance?
    inactive? && !new_record?
  end

  [:activation, :invitation, :welcome, :password_reset].each do |function|
    define_method("send_#{function}_message".intern) {
      send_functional_message(function)
    }
  end

  def send_functional_message(function, group=nil)
    reset_perishable_token!
    message = Message.functional(function, group)   # returns the standard functional message if no group is supplied, or no group message exists
    raise StandardError, "No #{function} message could be found" unless message
    message.deliver_to(self)
  end

  def generate_email_field_name
    self.email_field = Authlogic::Random.friendly_token
  end

  def is_user?
    !!self.user
  end

  def is_admin?
    is_user? && self.user.admin?
  end

  def create_password!
    self.clear_password = self.randomize_password # randomize_password is provided by authlogic
    self.save! unless self.new_record?
    self.clear_password
  end

  def find_homepage
    if homegroup = groups.with_home_page.first
      homegroup.homepage
    end
  end

  def can_see? (this)
    permitted_groups = this.permitted_groups
    permitted_groups.empty? or in_any_of_these_groups?(permitted_groups)
  end
    
  def in_any_of_these_groups? (grouplist)
    (grouplist & groups).any?
  end

  def is_in? (group)
    groups.include?(group)
  end
  
  # has_group? is ambiguous: with no argument it means 'is this reader grouped at all?'.
  def has_group?(group=nil)
    group.nil? ? groups.any? : is_in?(group)
  end
  
private

  def email_must_not_be_in_use
    reader = Reader.find_by_email(self.email)   # the finds will be site-scoped if appropriate
    user = User.find_by_email(self.email)
    if user && user != self.user
      errors.add :value, :taken_by_author
    elsif reader && reader != self
      errors.add :value, :taken
    else
      return true
    end
    return false
  end

  def existing_reader_keeping_password?
    !new_record? && !password_changed?
  end

  def update_user
    if self.user
      user_columns.each { |att| self.user.send("#{att.to_s}=", send(att)) if send("#{att.to_s}_changed?") }
      self.user.password_confirmation = password_confirmation if password_changed?
      self.user.save! if self.user.changed?
    end
  end
  
  def send_group_welcomes
    groups.each { |g| g.send_welcome_to(self) }
  end

  def send_group_invitation_message(group=nil)
    send_functional_message('invitation', group)
  end

end
