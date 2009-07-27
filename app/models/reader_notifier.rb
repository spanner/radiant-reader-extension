class ReaderNotifier < ActionMailer::Base
  
  def activation(reader)
    setup_email(reader)
    @subject += "Please activate your account at #{@body[:site_title]}"
    @body[:activation_url] = activate_reader_url(reader, :activation_code => reader.perishable_token)
  end

  def welcome(reader)
    setup_email(reader)
    @subject += "Welcome to #{@body[:site_title]}"
  end

  def password_reset(reader)
    setup_email(reader)
    @subject    += 'Reset your password'
    @body[:token] = reader.perishable_token
    @body[:url] = repassword_url(reader, reader.perishable_token)
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
      @body[:login_url] = new_reader_session_url
      @body[:my_url] = reader_url(reader)
      @body[:prefs_url] = edit_reader_url(reader)
    end
  
end
