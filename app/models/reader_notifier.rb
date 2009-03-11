class ReaderNotifier < ActionMailer::Base
  
  def activation(reader)
    setup_email(reader)
    @subject += "Please activate your account at #{@body[:site_title]}"
    @body[:activation_url] = reader_auto_activate_url(:id => reader.id, :activation_code => reader.activation_code)
  end

  def welcome(reader)
    setup_email(reader)
    @subject += "Welcome to #{@body[:site_title]}"
  end

  def password(reader)
    setup_email(reader)
    @subject += 'Reset your password'
    @body[:confirmation_url] = reader_repassword_url(:id => reader.id, :activation_code => reader.activation_code)
  end

  protected
  
    def setup_email(reader)
      site = reader.site if reader.respond_to?(:site)
      default_url_options[:host] = site ? site.base_domain : Radiant::Config['site.url'] || 'www.example.com'
      @from = site ? site.mail_from_address : Radiant::Config['readers.default_mail_from_address']
      @content_type = 'text/plain'
      @recipients = "#{reader.email}"
      @subject = ""
      @sent_on = Time.now
      @body[:reader] = reader
      @body[:sender] = site ? site.mail_from_name : Radiant::Config['readers.default_mail_from_name']
      @body[:site_title] = site ? site.name : Radiant::Config['site.title']
      @body[:site_url] = site ? site.base_domain : Radiant::Config['site.url']
      @body[:login_url] = reader_login_url
      @body[:my_url] = reader_self_url
      @body[:prefs_url] = reader_edit_self_url
    end
  
end
