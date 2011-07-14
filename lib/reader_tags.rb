module ReaderTags
  include Radiant::Taggable
  include ReaderHelper
  include ActionView::Helpers::TextHelper
  include GroupTags
  include MessageTags
  
  class TagError < StandardError; end

  ### standard reader css and javascript is just a starting point.

  tag 'reader_css' do |tag|
    %{<link rel="stylesheet" href="/stylesheets/reader.css" media="all" />}
  end

  tag 'reader_js' do |tag|
    %{<script type="text/javascript" src="/javascripts/reader.js"></script>}
  end

  ### tags displaying the set of readers
  
  desc %{
    Cycles through the (paginated) list of readers available for display. You can do this on 
    any page but if it's a ReaderPage you also get some access control and the ability to 
    click through to an individual reader.
    
    Please note that if you use this tag on a normal radiant page, all registered readers
    will be displayed, regardless of group-based or other access limitations. You really
    want to keep this tag for ReaderPages and GroupPages.
    
    *Usage:* 
    <pre><code><r:readers:each [limit=0] [offset=0] [order="asc|desc"] [by="position|title|..."] [extensions="png|pdf|doc"]>...</r:readers:each></code></pre>
  }    
  tag 'readers' do |tag|
    tag.expand
  end
  tag 'readers:each' do |tag|
    tag.locals.readers = get_readers(tag)
    tag.render('reader_list', tag.attr.dup, &tag.block)
  end

  # General purpose paginated reader lister. Potentially useful dryness.
  # Tag.locals.readers must be defined but can be empty.

  tag 'reader_list' do |tag|
    raise TagError, "r:reader_list: no readers to list" unless tag.locals.readers
    options = tag.attr.symbolize_keys
    result = []
    paging = pagination_find_options(tag)
    readers = paging ? tag.locals.readers.paginate(paging) : tag.locals.readers.all
    readers.each do |reader|
      tag.locals.reader = reader
      result << tag.expand
    end
    if paging && readers.total_pages > 1
      tag.locals.paginated_list = readers
      result << tag.render('pagination', tag.attr.dup)
    end
    result
  end

  ### Displaying or addressing an individual reader
  ### See also the r:recipient tags for use in email messages.

  desc %{
    The root 'reader' tag is not meant to be called directly.
    All it does is summon a reader object so that its fields can be displayed with eg.
    <pre><code><r:reader:name /></code></pre>
    
    On a ReaderPage, this will be the reader designated by the url. 
    
    Anywhere else, it will be the current reader (ie the one reading), provided
    we are on an uncached page.
  }
  tag 'reader' do |tag|
    tag.expand if get_reader(tag)
  end

  [:name, :forename, :email, :description, :login].each do |field|
    desc %{
      Displays the #{field} field of the current reader.
      <pre><code><r:reader:#{field} /></code></pre>
    }
    tag "reader:#{field}" do |tag|
      tag.locals.reader.send(field) if tag.locals.reader
    end
  end
  
  desc %{
    Displays the standard reader_welcome block, but only if a reader is present. For a block that shows an invitation to non-logged-in
    people, use @r:reader_welcome@
    
    <pre><code><r:reader:controls /></code></pre>
  }
  tag "reader:controls" do |tag|
    # if there's no reader, the reader: stem will not expand to render this tag.
    tag.render('reader_welcome')
  end
  
  desc %{
    Displays the standard block of reader controls: greeting, links to preferences, etc.
    If there is no reader, this will show a 'login or register' invitation, provided the reader.allow_registration? config entry is true. 
    If you don't want that, use @r:reader:controls@ instead: the reader: prefix means it will only show when a reader is present.
    
    If this tag appears on a cached page, we return an empty @<div class="remote_controls">@ suitable for ajaxing.
    
    <pre><code><r:reader_welcome /></code></pre>
  }
  tag "reader_welcome" do |tag|
    if tag.locals.page.cache?
      %{<div class="remote_controls"></div>}
    else
      if tag.locals.reader = Reader.current
        welcome = %{<span class="greeting">#{I18n.t('reader_extension.navigation.greeting', :name => reader.name)}</span> }
        links = []
        if tag.locals.reader.activated?
          links << %{<a href="#{edit_reader_path(tag.locals.reader)}">#{I18n.t('reader_extension.navigation.preferences')}</a>}
          links << %{<a href="#{reader_path(tag.locals.reader)}">#{I18n.t('reader_extension.navigation.account')}</a>}
          links << %{<a href="/admin">#{I18n.t('reader_extension.navigation.admin')}</a>} if tag.locals.reader.is_user?
          links << %{<a href="#{reader_logout_path}">#{I18n.t('reader_extension.navigation.log_out')}</a>}
        else
          welcome << I18n.t('reader_extension.navigation.activate')
        end
        %{<div class="controls"><p>} + welcome + links.join(%{<span class="separator"> | </span>}) + %{</p></div>}
      elsif Radiant::Config['reader.allow_registration?']
        %{<div class="controls"><p>#{I18n.t('reader_extension.navigation.welcome_please_log_in', :login_url => reader_login_url, :register_url => new_reader_url)}</p></div>}
      end
    end
  end
    
  desc %{
    Expands if there is a reader and we are on an uncached page.
    
    <pre><code><r:if_reader><div id="controls"><r:reader:controls /></r:if_reader></code></pre>
  }
  tag "if_reader" do |tag|
    tag.expand if get_reader(tag)
  end
  
  desc %{
    Expands if there is no reader or we are on a cached page.
    
    <pre><code><r:unless_reader>Please log in</r:unless_reader></code></pre>
  }
  tag "unless_reader" do |tag|
    tag.expand unless get_reader(tag)
  end

  desc %{
    Truncates the contained text or html to the specified length. Unless you supply a 
    html="true" parameter, all html tags will be removed before truncation. You probably
    don't want to do that: open tags will not be closed and the truncated
    text length will vary.
    
    <pre><code>
      <r:truncated words="30"><r:content part="body" /></r:truncated>
      <r:truncated chars="100" omission=" (continued)"><r:post:body /></r:truncated>
      <r:truncated words="100" allow_html="true"><r:reader:description /></r:truncated>
    </code></pre>
  }
  tag "truncated" do |tag|
    content = tag.expand
    tag.attr['words'] ||= tag.attr['length']
    omission = tag.attr['omission'] || '&hellip;'
    content = scrub_html(content) unless tag.attr['allow_html'] == 'true'
    if tag.attr['chars']
      truncate(content, :length => tag.attr['chars'].to_i, :omission => omission)
    else
      truncate_words(content, :length => tag.attr['words'].to_i, :omission => omission)   # defined in ReaderHelper
    end
  end
  
  deprecated_tag "truncate", :substitute => "truncated"

private

  def get_reader(tag)
    tag.locals.reader ||= if tag.attr['id']
      Reader.find_by_id(tag.attr['id'].to_i)
    elsif tag.locals.page.respond_to? :reader
      tag.locals.page.reader
    elsif !tag.locals.page.cache?
      Reader.current
    end
  end

  def get_readers(tag)
    attr = tag.attr.symbolize_keys
    readers = tag.locals.page.respond_to?(:reader) ? tag.locals.page.readers : Reader.scoped({})
    readers = readers.in_group(group) if group = attr[:group]
    by = attr[:by] || 'name'
    order = attr[:order] || 'ASC'
    readers = readers.scoped({
      :order => "#{by} #{order.upcase}",
      :limit => attr[:limit] || nil,
      :offset => attr[:offset] || nil
    })
    readers
  end
  
end
