class WhiteLister
  
  attr_reader :protocol_attributes, :protocol_separator
  attr_reader :bad_tags, :tags, :attributes, :protocols
  
  BAD_TAGS   = %w( script )
  TAGS       = %w( strong em b i p code pre tt output samp kbd 
                   var sub sup dfn cite big small address hr 
                   br div span h1 h2 h3 h4 h5 h6  ul ol li 
                   dt dd abbr acronym a img blockquote 
                   del ins fieldset legend )
  ATTRIBUTES = %w( href src width height alt cite datetime 
                   title class )
  PROTOCOLS  = %w( ed2k ftp http https irc mailto news 
                   gopher nntp telnet webcal xmpp callto feed )
  
  def initialize
    @protocol_attributes = Set.new %w(src href)
    @protocol_separator  = /:|(&#0*58)|(&#x70)|(%|&#37;)3A/
    @bad_tags   = BAD_TAGS.to_set
    @tags       = TAGS.to_set
    @attributes = ATTRIBUTES.to_set
    @protocols  = PROTOCOLS.to_set
    @default_bad_tag_handler = lambda do |node, bad| 
      @bad_tags.include?(bad) ? nil : node.to_s.gsub(/</, '&lt;')
    end
    @default_white_tag_handler = lambda { |node| node }
  end
  
  def white_list(html, options = {}, &block)
    return html if html.blank? || !html.include?('<')
    attrs   = Set.new(options[:attributes]).merge(@attributes)
    tags    = Set.new(options[:tags]      ).merge(@tags)
    block ||= @default_bad_tag_handler
    returning [] do |new_text|
      tokenizer = HTML::Tokenizer.new(html)
      bad       = nil
      while token = tokenizer.next
        node = HTML::Node.parse(nil, 0, 0, token, false)
        new_text << case node
          when HTML::Tag
            node.attributes.keys.each do |attr_name|
              value = node.attributes[attr_name].to_s
              if !attrs.include?(attr_name) || (protocol_attributes.include?(attr_name) && contains_bad_protocols?(value))
                node.attributes.delete(attr_name)
              else
                node.attributes[attr_name] = CGI::escapeHTML(value)
              end
            end if node.attributes
            if tags.include?(node.name)
              bad = nil
              @default_white_tag_handler.call(node)
            else
              bad = node.name
              block.call node, bad
              if node.closing == :self
                bad = nil
              end
            end
          else
            block.call node, bad
        end
      end
    end.join
  end
  
protected

  def contains_bad_protocols?(value)
    value =~ protocol_separator && !@protocols.include?(value.split(protocol_separator).first)
  end

end