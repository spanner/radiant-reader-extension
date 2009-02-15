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
      site = Page.current_site
      site_title = site.nil? ? Radiant::Config['site.title'] : site.name
      site_url = site.nil? ? Radiant::Config['site.url'] : site.base_domain
      default_url_options[:host] = site_url

      @from = (site.nil? || site.mail_from_address.blank?) ? Radiant::Config['readers.default_mail_from_address'] : site.mail_from_address
      @content_type = 'text/plain'
      @recipients = "#{reader.email}"
      @subject = ""
      @sent_on = Time.now
      @body[:reader] = reader
      @body[:sender] = (site.nil? || site.mail_from_name.blank?) ? Radiant::Config['readers.default_mail_from_name'] : site.mail_from_name
      @body[:site_title] = site_title
      @body[:site_url] = site_url
      @body[:login_url] = reader_login_url
      @body[:my_url] = reader_self_url
      @body[:prefs_url] = reader_edit_self_url
    end
  
end
