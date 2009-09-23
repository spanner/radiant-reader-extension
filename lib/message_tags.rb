module MessageTags
  include Radiant::Taggable
  
  class TagError < StandardError; end

  # this is a nasty hack: it places variable names for actionamailer to interpoloate
  # at this stage we don't actually have the recipient details

  desc %{
    The root 'recipient' tag is not meant to be called directly. 
    All it does is summon a reader object so that its fields can be displayed with eg.
    <pre><code><r:recipient:name /></code></pre>
  }
  tag 'recipient' do |tag|
    raise TagError, "no recipient" unless @reader
    tag.expand
  end
  
  [:name, :email, :description].each do |field|
    desc %{
      Only for use in email messages. Displays the #{field} field of the reader currently being emailed.
      <pre><code><r:recipient:#{field} /></code></pre>
    }
    tag "recipient:#{field}" do |tag|
      @reader.send(field)
    end
  end
  
  desc %{
    Only for use in email messages. Displays the url of the reader currently being emailed.
    <pre><code><r:recipient:url /></code></pre>
  }
  tag "recipient:url" do |tag|
    reader_url(@reader)
  end

  desc %{
    The root 'sender' tag is not meant to be called directly. 
    All it does is summon a sender object so that its fields can be displayed with eg.
    <pre><code><r:sender:name /></code></pre>
  }
  tag 'sender' do |tag|
    raise TagError, "no sender" unless @sender
    tag.expand
  end

  [:name, :email].each do |field|
    desc %{
      Only for use in email messages. Displays the #{field} field of the user sending the current message.
      <pre><code><r:sender:#{field} /></code></pre>
    }
    tag "sender:#{field}" do |tag|
      @sender.send(field)
    end
  end

end
