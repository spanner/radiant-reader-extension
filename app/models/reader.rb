require 'authlogic'
require 'digest/sha1'

class Reader < ActiveRecord::Base
  @@user_columns = [:name, :email, :login, :created_at, :password, :notes]
  cattr_accessor :user_columns
  cattr_accessor :current
  default_scope :order => 'name ASC'

  has_site if respond_to? :has_site

  acts_as_authentic do |config|
    config.validations_scope = :site_id if defined? Site
    config.transition_from_restful_authentication = true
    config.validate_email_field = false
    config.validate_login_field = false
  end

  belongs_to :user
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  has_many :message_readers
  has_many :messages, :through => :message_readers

  attr_accessor :current_password   # used for authentication on update
  attr_accessor :email_field        # used in blocking spam registrations
  
  before_update :update_user

  validates_presence_of :name, :email, :message => 'is required'
  validates_uniqueness_of :login, :message => "is already in use here", :allow_blank => true
  validate :email_must_not_be_in_use

  include RFC822
  validates_format_of :email, :with => RFC822_valid, :message => 'appears not to be an email address'
  validates_length_of :name, :maximum => 100, :allow_nil => true

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

  def self.find_by_login_or_email(login_or_email)
    reader = find(:first, :conditions => ["login = ? OR email = ?", login_or_email, login_or_email])
  end

  def forename
    read_attribute(:forename) || name.split(/\s/).first
  end

  def activate!
    self.activated_at = Time.now.utc
    self.save!
    self.send_welcome_message
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

  def send_functional_message(function)
    reset_perishable_token!
    message = Message.functional(function)
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

  def self.find_or_create_for_user(user)
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

  def create_password!
    self.clear_password = self.randomize_password # randomize_password is provided by authlogic
    self.save! unless self.new_record?
    self.clear_password
  end

private

  def email_must_not_be_in_use
    reader = Reader.find_by_email(self.email)   # the finds will be site-scoped if appropriate
    user = User.find_by_email(self.email)
    if user && user != self.user
      errors.add(:email, "belongs to an author already known here")
    elsif reader && reader != self
      errors.add(:email, "is already registered here")
    else
      return true
    end
    return false
  end

  def validate_length_of_password?
    new_record? or not password.to_s.empty?
  end

  def update_user
    if self.user
      user_columns.each { |att| self.user.send("#{att.to_s}=", send(att)) if send("#{att.to_s}_changed?") }
      self.user.password_confirmation = password_confirmation if password_changed?
      self.user.save! if self.user.changed?
    end
  end

end
