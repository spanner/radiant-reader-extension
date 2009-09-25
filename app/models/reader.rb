require 'digest/sha1'

class Reader < ActiveRecord::Base
  @@user_columns = [:name, :email, :login, :created_at, :password, :notes]
  cattr_accessor :user_columns
  cattr_accessor :current
  default_scope :order => 'name ASC'

  is_site_scoped if defined? ActiveRecord::SiteNotFound
    
  is_gravtastic :with => :email, :rating => 'PG', :size => 48
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

  before_save :set_login
  before_update :update_user

  validates_presence_of :name, :email, :message => 'is required'
  validates_uniqueness_of :login, :message => "is already in use here"
  validate :email_must_not_be_in_use

  include RFC822
  validates_format_of :email, :with => RFC822_valid, :message => 'appears not to be an email address'
  validates_length_of :name, :maximum => 100, :allow_nil => true, :message => '%d-character limit'
    
  def activate!
    self.activated_at = Time.now.utc
    self.save!
    self.send_welcome_message
  end

  def activated?
    !inactive?
  end

  def inactive?
    self.activated_at.nil? || self.activated_at > Time.now
  end

  def disable_perishable_token_maintenance?
    inactive? && !new_record?
  end

  [:activation, :invitation, :welcome, :password_reset].each do |function|
    define_method("send_#{function}_message".intern) {
      reset_perishable_token!
      message = Message.find_by_function("#{function}")
      message.deliver_to(self) if message
    }
  end
  
  def send_invitation_message_if_invited
    if UserActionObserver.current_user && !self.activated? && self.user != UserActionObserver.current_user
      send_invitation_message 
    end
  end
  
  def generate_email_field_name
    generate_password(32)
  end
  
  def generate_password(length=12)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
    Array.new(length, '').collect{chars[rand(chars.size)]}.join
  end
  
  def is_user?
    self.user ? true : false
  end

  def is_admin?
    self.user && self.user.admin? ? true : false
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
    
  protected

    def set_login
      self.login = self.email if self.login.blank?
    end
  
  private
  
    def email_must_not_be_in_use
      reader = Reader.find_by_email(self.email)   # the finds will be site-scoped if appropriate
      user = User.find_by_email(self.email)
      if user && user != self.user
        errors.add(:email, "belongs to an author here")
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
