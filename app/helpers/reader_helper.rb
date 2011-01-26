require 'sanitize'

module ReaderHelper
  def standard_gravatar_for(reader=nil, url=nil)
    size = Radiant::Config['forum.gravatar_size'] || 40
    url ||= reader_url(reader)
    gravatar = gravatar_for(reader, {:size => size, :default => "#{request.protocol}#{request.host_with_port}/images/furniture/no_gravatar.png"}, {:class => 'gravatar offset', :width => size, :height => size})
    link_to gravatar, url
  end

  def gravatar_for(reader=nil, gravatar_options={}, img_options ={})
    size = gravatar_options[:size]
    img_options[:size] ||= "#{size}x#{size}" if size
    img_options[:alt] ||= reader.name if reader
    if reader.nil? || reader.email.blank?
      image_tag gravatar_options[:default], img_options
    else
      image_tag gravatar_url(reader.email, gravatar_options), img_options
    end
  end

  def home_page_link(options={})
    home_page = Page.find_by_parent_id(nil)
    link_to home_page.title, home_page.url, options
  end

  def clean_textilize(text)
    Sanitize.clean(textilize(text), Sanitize::Config::RELAXED)
  end

  def clean_textilize_without_paragraph(text)
    textiled = clean_textilize(text)
    if textiled[0..2] == "<p>" then textiled = textiled[3..-1] end
    if textiled[-4..-1] == "</p>" then textiled = textiled[0..-5] end
    textiled
  end

  def truncate_words(text='', length=64, omission="...")
    return '' if text.blank?
    words = text.split
    omission = '' unless words.size > length
    words[0..(length-1)].join(" ") + omission
  end 
  
  def truncate_and_textilize(text, length=64)
    clean_textilize( truncate_words(text, length) )
  end

  def pagination_and_summary_for(list, name='')
    %{<div class="pagination">
        #{will_paginate list, :container => false}
        <span class="pagination_summary">
          #{pagination_summary(list, name)}
        </span>
      </div>
    }
  end
    
  def pagination_summary(list, name='')
    total = list.total_entries
    if list.empty?
      %{#{t('no')} #{name.pluralize}}
    else      
      name ||= t(list.first.class.to_s.underscore.gsub('_', ' '))
      if total == 1
        %{#{t('showing')} #{t('one')} #{name}}
      elsif list.current_page == 1 && total < list.per_page
        %{#{t('all')} #{total} #{name.pluralize}}
      else
        start = list.offset + 1
        finish = ((list.offset + list.per_page) < list.total_entries) ? list.offset + list.per_page : list.total_entries
        %{#{start} #{t('to')} #{finish} #{t('of')} #{total} #{name.pluralize}}
      end
    end
  end
end
