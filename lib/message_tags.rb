module MessageTags
  include Radiant::Taggable
  
  class TagError < StandardError; end

  # this is a nasty hack: it places variable names for actionamailer to interpoloate
  # at this stage we don't actually have the recipient details

  desc %{
    The root 'site' tag is not meant to be called directly. 
    All it does is to prepare the way for eg.
    <pre><code><r:site:url /></code></pre>
  }
  tag 'site' do |tag|
    raise TagError, "no site" unless tag.locals.site = @mailer_vars[:@site]
    tag.expand
  end
  tag 'site:name' do |tag|
    if defined?(Site) && tag.locals.site.is_a(Site)
      tag.locals.site.title
    else
      tag.locals.site[:title]
    end
  end
  tag 'site:url' do |tag|
    if defined?(Site) && tag.locals.site.is_a(Site)
      tag.locals.site.base_domain
    else
      tag.locals.site[:url]
    end
  end
  tag 'site:login_url' do |tag|
    reader_login_url(:host => @mailer_vars[:@host])
  end
  

  desc %{
    The root 'recipient' tag is not meant to be called directly. 
    All it does is summon a reader object so that its fields can be displayed with eg.
    <pre><code><r:recipient:name /></code></pre>
  }
  tag 'recipient' do |tag|
    raise TagError, "no recipient" unless tag.locals.recipient = @mailer_vars[:@reader]
    tag.expand
  end
  
  [:name, :email, :description, :login].each do |field|
    desc %{
      Only for use in email messages. Displays the #{field} field of the reader currently being emailed.
      <pre><code><r:recipient:#{field} /></code></pre>
    }
    tag "recipient:#{field}" do |tag|
      tag.locals.recipient.send(field)
    end
  end
  
  desc %{
    Only for use in email messages. Displays the password of the reader currently being emailed, if we still have it.

    (After the first successful login we forget the cleartext version of their password, so you only want to use this 
    tag in welcome and activation messages.)
    
    <pre><code><r:recipient:url /></code></pre>
  }
  tag "recipient:password" do |tag|
    tag.locals.recipient.clear_password || "<encrypted>"
  end
  
  desc %{
    Only for use in email messages. Displays the me-page url of the reader currently being emailed.
    <pre><code><r:recipient:url /></code></pre>
  }
  tag "recipient:url" do |tag|
    reader_url(tag.locals.recipient, :host => @mailer_vars[:@host])
  end

  desc %{
    Only for use in email messages. Displays the preferences url of the reader currently being emailed.
    <pre><code><r:recipient:url /></code></pre>
  }
  tag "recipient:edit_url" do |tag|
    edit_reader_url(tag.locals.recipient, :host => @mailer_vars[:@host])
  end

  desc %{
    Only for use in email messages. Displays the preferences url of the reader currently being emailed.
    <pre><code><r:recipient:url /></code></pre>
  }
  tag "recipient:activation_url" do |tag|
    activate_me_url(tag.locals.recipient, :activation_code => tag.locals.recipient.perishable_token, :host => @mailer_vars[:@host])
  end

  desc %{
    The root 'sender' tag is not meant to be called directly. 
    All it does is summon a sender object so that its fields can be displayed with eg.
    <pre><code><r:sender:name /></code></pre>
  }
  tag 'sender' do |tag|
    raise TagError, "no sender" unless tag.locals.sender = @mailer_vars[:@sender]
    tag.expand
  end

  [:name, :email].each do |field|
    desc %{
      Only for use in email messages. Displays the #{field} field of the user sending the current message.
      <pre><code><r:sender:#{field} /></code></pre>
    }
    tag "sender:#{field}" do |tag|
      tag.locals.sender.send(field)
    end
  end

end
