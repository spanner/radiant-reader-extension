require 'digest/sha1'

class Reader < ActiveRecord::Base
  is_site_scoped
  is_gravtastic :with => :email, :rating => 'PG', :size => 48
  cattr_accessor :current_reader

  belongs_to :user
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  
  validates_uniqueness_of :login, :message => "already in use"
  validate :email_must_not_be_in_use
  validates_confirmation_of :password, :message => 'must match confirmation', :if => :confirm_password?
  validates_presence_of :name, :login, :email, :message => 'required'
  validates_presence_of :password, :password_confirmation, :message => 'required', :if => :new_record?

  include RFC822
  validates_format_of :email, :with => RFC822_valid, :message => 'appears not to be an email address'

  validates_length_of :name, :maximum => 100, :allow_nil => true, :message => '%d-character limit'
  validates_length_of :password, :within => 5..40, :allow_nil => true, :too_long => '%d-character limit', :too_short => '%d-character minimum', :if => :validate_length_of_password?
  validates_length_of :email, :maximum => 255, :allow_nil => true, :message => '%d-character limit'
  validates_numericality_of :id, :only_integer => true, :allow_nil => true, :message => 'must be a number'

  attr_writer :confirm_password
  attr_accessor :current_password   # used for authentication on update and (since it's there) to mention password in initial email

  before_validation :set_login
  before_create :generate_activation_code
  before_create :encrypt_password
  after_create :send_activation_message_if_necessary
  before_update :update_user
  before_update :encrypt_password_unless_empty_or_unchanged
  
  @@user_columns = [:name, :email, :login, :created_at, :password, :notes]
  cattr_accessor :user_columns

  def sha1(phrase)
    Digest::SHA1.hexdigest("--#{salt}--#{phrase}--")
  end

  def self.authenticate(login, password)
    reader = find_by_login(login)
    if reader && reader.authenticated?(password)
      reader.previous_login = reader.last_login
      reader.last_login = Time.now
      reader.timestamp
      reader
    end
  end
    
  def authenticated?(pw)
    self.password == sha1(pw)
  end
  
  def timestamp(at=Time.now)
    self.last_seen = at
    self.save
  end

  def after_initialize
    @confirm_password = true
  end
  
  def confirm_password?
    @confirm_password
  end

  def activated?
    !self.activated_at.nil?
  end
  
  def activate!(code)
    return true if self.activated?
    return false unless code == self.activation_code
    self.activation_code = nil
    self.activated_at = Time.now
    self.save!
    self.send_welcome_message
    true
  end

  def repassword
    self.provisional_password = generate_password(12)
    self.generate_activation_code
    self.save!
    self.send_password_message
  end
  
  def confirm_password(code)
    return false unless code == self.activation_code
    self.password = provisional_password
    self.current_password = provisional_password
    self.provisional_password = nil
    self.activation_code = nil
    self.save!
  end

  def remember_me
    update_attribute(:session_token, sha1(Time.now + Radiant::Config['session_timeout'].to_i)) unless self.session_token?
  end

  def forget_me
    update_attribute(:session_token, nil)
  end
    
  ['activation', 'welcome', 'account', 'password'].each do |message|
    define_method("send_#{message}_message".intern) { ReaderNotifier.send("deliver_#{message}".intern, self) }
  end
    
  def generate_email_field_name
    generate_password(32)
  end
  
  def generate_password(length=12)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
    Array.new(length, '').collect{chars[rand(chars.size)]}.join
  end
  
  # this makes more sense in other extensions that modify reader login behaviour. 
  # here we just default to the reader's account page

  def homepage
    "/readers/#{id}"
  end
  
  def is_user?
    self.user ? true : false
  end

  def is_admin?
    self.user && self.user.admin? ? true : false
  end

  def self.find_or_create_for_user(user)
    reader = self.find_or_create_by_user_id(user.id)
    if reader.new_record?
      user_columns.each { |att| reader.send("#{att.to_s}=", user.send(att)) }
      reader.activated_at = Time.now
      reader.save(false)
    end
    reader
  end
  
  protected

    def generate_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

    def set_login
      self.login = self.email if self.new_record? && self.login.blank?
    end
  
  private
  
    def email_must_not_be_in_use
      reader = Reader.find_by_email(self.email)   # the finds will be site-scoped if appropriate
      user = User.find_by_email(self.email)
      if user && user != self.user
        errors.add(:email, "belongs to an author here: do you need to log in?")
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
  
    def send_activation_message_if_necessary
      if self.activated?
        self.activation_code = nil
        self.save!
      else
        self.send_activation_message 
      end
    end
    
    def encrypt_password
      if self.user && self.password == self.user.password #it's already encrypted
        self.salt = self.user.salt
      else
        self.current_password = password
        self.salt = Digest::SHA1.hexdigest("--#{Time.now}--#{login}--rich_tea--")
        self.password = sha1(password)
      end
    end
    
    def update_user
      if self.user
        user_columns.each { |att| self.user.send("#{att.to_s}=", send(att)) if send("#{att.to_s}_changed?") }
        self.user.password_confirmation = self.password_confirmation if self.password_changed?
        self.user.save! if self.user.changed?
      end
    end

    def encrypt_password_unless_empty_or_unchanged
      reader = self.class.find(self.id)
      case password
      when ''
        self.password = reader.password
      when reader.password  
      else
        encrypt_password
      end
    end
    
end
