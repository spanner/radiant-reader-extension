module ReaderTags
  include Radiant::Taggable
  
  class TagError < StandardError; end


  # I can see this causing problems: will change soon

  desc %{
    The root 'site' tag is not meant to be called directly. 
    All it does is to prepare the way for eg.
    <pre><code><r:site:url /></code></pre>
  }
  tag 'site' do |tag|
    raise TagError, "r:site currently only works in email" unless @mailer_vars
    raise TagError, "no site" unless tag.locals.site = @mailer_vars[:@site]
    tag.expand
  end
  tag 'site:name' do |tag|
    if defined?(Site) && tag.locals.site.is_a?(Site)
      tag.locals.site.name
    else
      tag.locals.site[:name]
    end
  end
  tag 'site:url' do |tag|
    if defined?(Site) && tag.locals.site.is_a?(Site)
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
    raise TagError, "r:recipient only works in email" unless @mailer_vars
    raise TagError, "no recipient" unless tag.locals.recipient = @mailer_vars[:@reader]
    tag.expand
  end
  
  [:name, :forename, :email, :description, :login].each do |field|
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
    Only for use in email messages. Displays the address that will activate the current reader account.
    <pre><code><r:recipient:activation_url /></code></pre>
  }
  tag "recipient:activation_url" do |tag|
    activate_me_url(tag.locals.recipient, :activation_code => tag.locals.recipient.perishable_token, :host => @mailer_vars[:@host])
  end

  desc %{
    Only for use in email messages. Displays the address that will bring up a new-password form for the current reader account.
    <pre><code><r:recipient:repassword_url /></code></pre>
  }
  tag "recipient:repassword_url" do |tag|
    repassword_url(tag.locals.recipient, :confirmation_code => tag.locals.recipient.perishable_token, :host => @mailer_vars[:@host])
  end

  desc %{
    The root 'sender' tag is not meant to be called directly. 
    All it does is summon a sender object so that its fields can be displayed with eg.
    <pre><code><r:sender:name /></code></pre>
  }
  tag 'sender' do |tag|
    raise TagError, "r:sender only works in email" unless @mailer_vars
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

  # and for referring to messages on pages
  # at the moment this only works inside r:reader:messages:each or r:group:messages:each, 
  # both of which are defined in reader_group
  # but soon there will be a conditional r:messages:each tag here too

  desc %{
    The root 'message' tag is not meant to be called directly. 
    All it does is summon a message object so that its fields can be displayed with eg.
    <pre><code><r:message:subject /></code></pre>
  }
  tag 'message' do |tag|
    raise TagError, "no message!" unless tag.locals.message
    tag.expand
  end

  desc %{
    Displays the message subject.
    
    <pre><code><r:message:subject /></code></pre>
  }
  tag "message:subject" do |tag|
    tag.locals.message.subject
  end

  desc %{
    Displays the formatted message body.
    
    <pre><code><r:message:body /></code></pre>
  }
  tag "message:body" do |tag|
    tag.locals.message.filtered_body
  end

  desc %{
    Returns the url of the show-message page.
    
    <pre><code><r:message:url /></code></pre>
  }
  tag "message:url" do |tag|
    message_path(tag.locals.message)
  end

  desc %{
    Displays a link to the show-message page.
    
    <pre><code><r:message:link /></code></pre>
  }
  tag "message:link" do |tag|
    options = tag.attr.dup
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('message:subject')
    %{<a href="#{tag.render('message:url')}"#{attributes}>#{text}</a>}
  end



  desc %{
    The root 'reader' tag is not meant to be called directly.
    All it does is summon a reader object so that its fields can be displayed with eg.
    <pre><code><r:reader:name /></code></pre>
    
    This will only work on an access-protected page and should never be used on a cached page, because everyone will see it.
  }
  tag 'reader' do |tag|
    tag.expand if !tag.locals.page.cache? && tag.locals.reader = Reader.current
  end

  [:name, :forename, :email, :description, :login].each do |field|
    desc %{
      Displays the #{field} field of the current reader.
      <pre><code><r:reader:#{field} /></code></pre>
    }
    tag "reader:#{field}" do |tag|
      tag.locals.reader.send(field)
    end
  end

  desc %{
    Expands if the current reader has been sent any messages.
    
    <pre><code><r:reader:if_messages>...</r:reader:if_messages /></code></pre>
  }
  tag "reader:if_messages" do |tag|
    tag.expand if tag.locals.reader.messages.any?
  end

  desc %{
    Expands if the current reader has not been sent any messages.
    
    <pre><code><r:reader:unless_messages>...</r:reader:unless_messages /></code></pre>
  }
  tag "reader:unless_messages" do |tag|
    tag.expand unless tag.locals.reader.messages.any?
  end

  desc %{
    Loops through the messages that belong to this reader (whether they have been sent or not, so at the moment this may include drafts).
    
    <pre><code><r:reader:messages:each>...</r:reader:messages:each /></code></pre>
  }
  tag "reader:messages" do |tag|
    tag.locals.messages = tag.locals.reader.messages
    tag.expand if tag.locals.messages.any?
  end
  tag "reader:messages:each" do |tag|
    result = []
    tag.locals.messages.each do |message|
      tag.locals.message = message
      result << tag.expand
    end
    result
  end
  
  desc %{
    Displays the standard reader_welcome block, but only if a reader is present. For a block that shows an invitation to non-logged-in
    people, use @r:reader_welcome@
    
    <pre><code><r:reader:controls /></code></pre>
  }
  tag "reader:controls" do |tag|
    tag.render('reader_controls')
  end
  
  desc %{
    Displays the standard block of reader controls: greeting, links to preferences, etc.
    If there is no reader, this will show a 'login or register' invitation, provided the reader.allow_registration? config entry is true. 
    If you don't want that, use @r:reader:controls@ instead: being inside the reader tag it will only show when a reader is present.
    
    If this tag appears on a cached page, we return an empty @<div class="remote_controls">@ into which you can drop whatever you like.
    
    <pre><code><r:reader_welcome /></code></pre>
  }
  tag "reader_welcome" do |tag|
    if tag.locals.page.cache?
      %{<div class="remote_controls"></div>}
    else
      if tag.locals.reader = Reader.current
        welcome = %{<span class="greeting">Hello #{tag.render('reader:name')}.</span> }
        links = []
        links << %{<a href="#{edit_reader_path(tag.locals.reader)}">Preferences</a>}
        links << %{<a href="#{reader_path(tag.locals.reader)}">Your page</a>}
        links << %{<a href="/admin">Admin</a>} if tag.locals.reader.is_user?
        links << %{<a href="#{reader_logout_path}">Log out</a>}
        %{<div class="controls"><p>} + welcome + links.join(%{<span class="separator"> | </span>}) + %{</p></div>}
      elsif Radiant::Config['reader.allow_registration?']
        %{<div class="controls"><p><span class="greeting">Welcome!</span> To take part, please <a href="#{reader_login_path}">log in</a> or <a href="#{reader_register_path}">register</a>.</p></div>}
      end
    end
  end
    
  desc %{
    Expands only if there is a reader and we are on an uncached page.
    
    <pre><code><r:if_reader><div id="controls"><r:reader:controls /></r:if_reader></code></pre>
  }
  tag "if_reader" do |tag|
    tag.expand if !tag.locals.page.cache? && tag.locals.reader = Reader.current
  end
  
  desc %{
    Expands only if there is no reader or we are not on an uncached page.
    
    <pre><code><r:unless_reader>Please log in</r:unless_reader></code></pre>
  }
  tag "unless_reader" do |tag|
    tag.expand unless Reader.current && !tag.locals.page.cache?
  end
  

end
