require 'digest/sha1'

class Reader < ActiveRecord::Base
  is_site_scoped
  is_gravtastic 
  cattr_accessor :current_reader
  
  validates_uniqueness_of :login, :message => "already in use", :scope => :site_id
  validates_uniqueness_of :email, :message => "already in use", :scope => :site_id
  validates_confirmation_of :password, :message => 'must match confirmation', :if => :confirm_password?
  validates_presence_of :name, :login, :email, :message => 'required'
  validates_presence_of :password, :password_confirmation, :message => 'required', :if => :new_record?
  validates_format_of :email, :message => 'invalid email address', :allow_nil => true, :with => /^$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_length_of :name, :maximum => 100, :allow_nil => true, :message => '%d-character limit'
  validates_length_of :login, :within => 3..40, :allow_nil => true, :too_long => '%d-character limit', :too_short => '%d-character minimum'
  validates_length_of :password, :within => 5..40, :allow_nil => true, :too_long => '%d-character limit', :too_short => '%d-character minimum', :if => :validate_length_of_password?
  validates_length_of :email, :maximum => 255, :allow_nil => true, :message => '%d-character limit'
  validates_numericality_of :id, :only_integer => true, :allow_nil => true, :message => 'must be a number'

  attr_writer :confirm_password
  attr_accessor :current_password   # used for authentication on update and (since it's there) to mention password in initial email

  before_validation :set_login
  before_create :generate_activation_code
  before_create :encrypt_password
  after_create :send_activation_message
  before_update :encrypt_password_unless_empty_or_unchanged

  def sha1(phrase)
    Digest::SHA1.hexdigest("--#{salt}--#{phrase}--")
  end

  def self.authenticate(login, password)
    reader = find_by_login(login)
    if reader && reader.authenticated?(password)
      reader
    end
  end
  
  def authenticated?(pw)
    self.password == sha1(pw)
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
    logger.warn "!!! forget me"
    update_attribute(:session_token, nil)
  end
    
  ['activation', 'welcome', 'account', 'password'].each do |message|
    define_method("send_#{message}_message".intern) { ReaderNotifier.send("deliver_#{message}".intern, self) }
  end
  
  protected

    def generate_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

    def set_login
      self.login = self.email if self.new_record? && self.login.blank?
    end
  
  private
  
    def validate_length_of_password?
      new_record? or not password.to_s.empty?
    end
  
    def encrypt_password
      self.current_password = password
      self.salt = Digest::SHA1.hexdigest("--#{Time.now}--#{login}--rich_tea--")
      self.password = sha1(password)
    end
    
    def encrypt_password_unless_empty_or_unchanged
      user = self.class.find(self.id)
      case password
      when ''
        self.password = user.password
      when user.password  
      else
        encrypt_password
      end
    end

    def generate_password(length=8)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
      Array.new(length, '').collect{chars[rand(chars.size)]}.join
    end

end
