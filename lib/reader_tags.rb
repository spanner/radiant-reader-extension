module ReaderTags
  include Radiant::Taggable
  include ReaderHelper
  include GroupTags
  include MessageTags
  
  class TagError < StandardError; end

  # I need to find a better way to do this, but this gives a starting point

  tag 'reader_css' do |tag|
    %{<link rel="stylesheet" href="/stylesheets/reader.css" media="all" />}
  end

  tag 'reader_js' do |tag|
    %{<script type="text/javascript" src="/javascripts/reader.js"></script>}
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
    tag.render('reader_welcome')
  end
  
  desc %{
    Displays the standard block of reader controls: greeting, links to preferences, etc.
    If there is no reader, this will show a 'login or register' invitation, provided the reader.allow_registration? config entry is true. 
    If you don't want that, use @r:reader:controls@ instead: the reader: prefix means it will only show when a reader is present.
    
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
        if tag.locals.reader.activated?
          links << %{<a href="#{edit_reader_path(tag.locals.reader)}">Preferences</a>}
          links << %{<a href="#{reader_path(tag.locals.reader)}">Your page</a>}
          links << %{<a href="/admin">Admin</a>} if tag.locals.reader.is_user?
          links << %{<a href="#{reader_logout_path}">Log out</a>}
        else
          welcome << "Please check your email and activate your account."
        end
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
