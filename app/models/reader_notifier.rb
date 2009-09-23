class ReaderNotifier < ActionMailer::Base
  radiant_layout { |mailer| mailer.layout_for(:email) }
  
  def activation(reader)
    setup_email(reader)
    @subject += "Please activate your account at #{@body[:site_url]}"
    @body[:activation_url] = activate_me_url(reader, :activation_code => reader.perishable_token)
  end

  def invitation(reader)
    setup_email(reader)
    @body[:sender] = UserActionObserver.current_user.name
    @from = UserActionObserver.current_user.email
    @subject += "You are invited to join the #{@body[:site_title]} site"
    @body[:activation_url] = activate_me_url(reader, :activation_code => reader.perishable_token)
  end

  def welcome(reader)
    setup_email(reader)
    @subject += "Welcome to #{@body[:site_url]}"
  end

  def password_reset(reader)
    setup_email(reader)
    @subject    += 'Reset your password'
    @body[:token] = reader.perishable_token
    @body[:url] = repassword_url(reader, reader.perishable_token)
  end
  
  def message(reader, message)
    setup_email reader
    from message.created_by.email
    subject message.subject
    @body[:title] = message.subject
    @body[:message] = message.filtered_body
    @body[:sender] = message.created_by
  end

protected

  def setup_email(reader)
    site = reader.site if reader.respond_to?(:site)
    prefix = site ? site.abbreviation : Radiant::Config['site.mail_prefix']
    default_url_options[:host] = site ? site.base_domain : Radiant::Config['site.url'] || 'www.example.com'

    content_type("text/html")
    from(site ? site.mail_from_address : Radiant::Config['site.mail_from_address'])
    subject(prefix ? "[#{prefix}] " : "")
    recipients(reader.email)
    sent_on(Time.now)
    body({
     :reader => reader,
     :sender => site ? site.mail_from_name : Radiant::Config['site.mail_from_name'],
     :site_title => site ? site.name : Radiant::Config['site.title'],
     :site_url => site ? site.base_domain : Radiant::Config['site.url'],
     :login_url => reader_login_url,
     :my_url => reader_url(reader),
     :prefs_url => edit_reader_url(reader)
    })
  end

end
