class DefaultSettings < ActiveRecord::Migration
  def self.up
    Radiant::Config['reader.allow_registration?'] ||= true
    Radiant::Config['reader.require_confirmation?'] ||= true
    Radiant::Config['site.url'] ||= 'www.example.com'
    Radiant::Config['site.title'] ||= 'Your site name here'
    Radiant::Config['reader.mail_from_name'] ||= "Administrator"
    Radiant::Config['reader.mail_from_address'] ||= "admin@example.com"
  end

  def self.down
  end
end
