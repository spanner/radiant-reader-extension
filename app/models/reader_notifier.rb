class ReaderNotifier < ActionMailer::Base
  # this sets a default that will be overridden by the layout association of each message as it is sent out
  radiant_layout { |mailer| 
    mailer.default_layout_for(:email)
  }
  
  def message(reader, message, sender=nil)
    site = reader.site if reader.respond_to?(:site)
    prefix = site ? site.abbreviation : Radiant::Config['site.mail_prefix']
    host = site ? site.base_domain : Radiant::Config['site.url'] || 'www.example.com'
    default_url_options[:host] = host
    sender ||= message.created_by

    message_layout(message.layout) if message.layout
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
        :name => Radiant::Config['site.name'],
        :url => Radiant::Config['site.url']
      }
    })
  end

end
