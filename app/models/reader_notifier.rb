class ReaderNotifier < ActionMailer::Base
  radiant_layout { |mailer| mailer.layout_for(:email) }
  
  def message(reader, message, sender=nil)
    site = reader.site if reader.respond_to?(:site)
    prefix = site ? site.abbreviation : Radiant::Config['site.mail_prefix']
    host = site ? site.base_domain : Radiant::Config['site.url'] || 'www.example.com'
    default_url_options[:host] = host
    sender ||= message.created_by
    
    content_type("text/html")
    subject (prefix || '') + message.subject
    recipients(reader.email)
    from message.created_by.email
    subject message.subject
    sent_on(Time.now)
    body({
      :host => host,
      :title => message.subject,
      :message => message.filtered_body,
      :sender => sender,
      :reader => reader,
      :site => site || {
        :title => Radiant::Config['site.title'],
        :url => Radiant::Config['site.url']
      }
    })
  end

end
