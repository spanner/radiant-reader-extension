require 'authlogic'
require 'digest/sha1'
require 'snail'
require 'vcard'
require "fastercsv"

class Reader < ActiveRecord::Base
  @@user_columns = %w{name email created_at password password_confirmation notes}
  cattr_accessor :user_columns
  cattr_accessor :current
  attr_accessor :email_field, :newly_activated, :skip_user_update

  acts_as_authentic do |config|
    config.validations_scope = :site_id if defined? Site
    config.transition_from_restful_authentication = true
    config.validate_email_field = false
    config.validate_login_field = false
    config.validate_password_field = false
  end

  belongs_to :user
  before_update :update_user
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  has_many :message_readers
  has_many :messages, :through => :message_readers
  has_many :memberships
  has_many :groups, :through => :memberships, :uniq => true
  accepts_nested_attributes_for :memberships

  before_validation :combine_names

  validates_presence_of :name, :forename, :surname, :email
  validates_uniqueness_of :nickname, :allow_blank => true
  validates_length_of :name, :forename, :surname, :maximum => 100, :allow_nil => false
  validates_length_of :password, :minimum => 5, :allow_nil => false, :unless => :existing_reader_keeping_password?
  # validates_format_of :password, :with => /[^A-Za-z]/, :unless => :existing_reader_keeping_password?  # we have to match radiant so that users can log in both ways
  validates_confirmation_of :password, :unless => :existing_reader_keeping_password?
  validate :email_must_not_be_in_use

  include RFC822
  validates_format_of :email, :with => RFC822_valid

  default_scope :order => 'name ASC'
  named_scope :any
  named_scope :none, { :conditions => "1 = 0" }   # nasty! but doesn't break chains
  named_scope :active, :conditions => "activated_at IS NOT NULL"
  named_scope :inactive, :conditions => "activated_at IS NULL"
  named_scope :imported, :conditions => "old_id IS NOT NULL"

  named_scope :except, lambda { |readers|
    readers = [readers].flatten.compact
    if readers.any?
      { :conditions => ["NOT readers.id IN (#{readers.map{"?"}.join(',')})", *readers.map(&:id)] }
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

  def self.find_by_nickname_or_email(nickname_or_email)
    reader = find(:first, :conditions => ["nickname = ? OR email = ?", nickname_or_email, nickname_or_email])
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
  
  def self.visible_to(reader=nil)
    case Radiant.config['reader.directory_visibility']
    when 'public'
      self.all
    when 'private'
      reader ? self.all : self.none
    when 'grouped'
      reader ? self.in_groups(reader.all_visible_group_ids) : self.none
    else
      self.none
    end
  end
  
  def visible_to?(reader=nil)
    (reader && (reader == self)) || self.class.visible_to(reader).map(&:id).include?(self.id)
  end
  
  # returns a useful list of the groups that this person is in and all their ancestor groups.
  # for most authorisation purposes, that's the set of groups of which this reader is considered a member.
  # 
  # Returns a scope.
  #
  def all_groups
    Group.find_these(all_group_ids)
  end
  
  def all_group_ids
    self.groups.map(&:path_ids).flatten.uniq
  end
  
  # Returns a list of the groups that this person is in along with their whole tree of super and subgroups.
  # That's the list of groups that this person can see. It is larger than the list of groups that confer permission:
  # this reader can see subgroups of his own groups in the directory, but he can't see their pages.
  #
  def all_visible_groups
    Group.find_these(all_visible_group_ids)
  end

  def all_visible_group_ids
    self.groups.map(&:tree_ids).flatten.uniq
  end
  
  def can_see? (this)
    permitted_groups = this.permitted_groups
    permitted_groups.empty? or in_any_of_these_groups?(permitted_groups)
  end
    
  def in_any_of_these_groups? (grouplist)
    (grouplist & all_groups).any?
  end

  def membership_of(group)
    memberships.of(group).first
  end

  def has_group? (group)
    !!membership_of(group)
  end
  alias :is_in? :has_group?
  
  def is_grouped?
    groups.any?
  end
  
  def preferred_name
    nickname? ? nickname : name
  end
  
  def postal_address?
    !post_line1.blank? && !post_city.blank?
  end
  
  def postal_address
    Snail.new(
      :line_1 => post_line1,
      :line_2 => post_line2,
      :city => post_city,
      :region => post_province,
      :postal_code => postcode,
      :country => post_country
    )
  end
  
  def vcard
  	@vcard ||= Vpim::Vcard::Maker.make2 do |maker|
  		maker.add_name do |n|
  		  n.prefix = honorific || ""
  		  n.given = forename || ""
  		  n.family = surname || ""
		  end
  		maker.add_addr {|a| 
  		  a.location = 'home' # until we do this properly with multiple contact sets
        a.country = post_country || ""
        a.region = post_province || ""
        a.locality = post_city || ""
        a.street = [post_line1, post_line2].compact.join("\n")
        a.postalcode = postcode || ""
  		}
  		maker.add_tel phone { |t| t.location = 'home' } unless phone.blank?
  		maker.add_tel mobile { |t| t.location = 'cell' } unless mobile.blank?
  		maker.add_email email { |e| t.location = 'home' }
  	end
  end
  
  def filename
    name.downcase.gsub(/\W/, '_')
  end
  
  def activate!
    self.activated_at = Time.now.utc
    self.newly_activated = true
    self.save!
    send_welcome_message
    send_group_welcomes
  end

  def activated?
    !inactive?
  end
  
  def newly_activated?
    !!newly_activated
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
    self.clear_password = self.password_confirmation = self.randomize_password # randomize_password is provided by authlogic
    self.save! unless self.new_record?
    self.clear_password
  end

  def find_homepage
    if homegroup = groups.with_home_page.first
      homegroup.homepage
    end
  end
  
  def home_url
    if homepage = self.find_homepage
      homepage.url
    else
      nil
    end
  end
  
  # Generates a csv file listing the supplied group of readers.
  # No access checks are performed here.
  #
  def self.csv_for(readers=[])
    columns = %w{forename surname email phone mobile postal_address}
    FasterCSV.generate do |csv|
      csv << columns.map { |f| I18n.t("activerecord.attributes.reader.#{f}") }
      readers.each { |r| csv << columns.map{ |f| r.send(f.to_sym) } }
    end
  end

  # Generates a vcard file containing the supplied group of readers.
  # No access checks are performed here.
  #
  def self.vcards_for(readers=[])
    readers.map(&:vcard).join("\n")
  end
  
private

  def combine_names
    if self.name?
      self.forename ||= self.name.split(/\s+/).first
      self.surname ||= self.name.split(/\s+/).last
    else
      self.name = "#{self.forename} #{self.surname}"
    end
  end

  def email_must_not_be_in_use
    reader = Reader.find_by_email(self.email)
    user = User.find_by_email(self.email)
    if user && user != self.user
      errors.add :email, :taken_by_author
    elsif reader && reader != self
      errors.add :email, :taken
    else
      return true
    end
    return false
  end

  def existing_reader_keeping_password?
    !new_record? && !password_changed?
  end

  def update_user
    if self.user && !self.skip_user_update
      changed_columns = Reader.user_columns & self.changed
      att = self.attributes.slice(*changed_columns)
      att['password'] = self.password if self.crypted_password_changed?
      self.user.send :update_with, att if att.any?
    end
    true
  end
  
  def update_with(att)
    self.skip_user_update = true
    if att['password']
      att["clear_password"] = att["password_confirmation"] = att["password"]
    end
    self.update_attributes(att)
    self.skip_user_update = false
  end
  
  def send_group_welcomes
    groups.each { |g| g.send_welcome_to(self) }
  end

  def send_group_invitation_message(group=nil)
    send_functional_message('group_invitation', group)
  end

end
