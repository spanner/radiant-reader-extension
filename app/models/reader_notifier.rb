class ReaderNotifier < ActionMailer::Base

  # this sets a default that will be overridden by the layout association of each message as it is sent out
  radiant_layout lambda { Radiant::Config['email.layout'] || 'email'}
  
  def message(reader, message, sender=nil)
    site = reader.site if reader.respond_to?(:site)
    prefix = site ? site.abbreviation : Radiant::Config['email.prefix']
    host = site ? site.base_domain : Radiant::Config['site.domain'] || 'www.example.com'
    default_url_options[:host] = host
    sender = Radiant::Config['email.name'] || "sender_not_configured"
    sender_address = Radiant::Config['email.address'] || "admin@#{host}"

    message_layout(message.layout) if message.layout
    content_type("text/html")
    subject (prefix || '') + message.subject
    recipients(reader.email)
    from ["#{sender} <#{sender_address}>"]
    reply_to = [sender_address]
    subject message.subject
    sent_on(Time.now)

    body({
      :host => host,
      :title => message.subject,
      :message => message.filtered_body,
      :sender => sender,
      :reply_to => sender_address,
      :reader => reader,
      :site => site || {
        :name => Radiant::Config['site.title'],
        :url => Radiant::Config['site.domain']
      }
    })
  end

end
