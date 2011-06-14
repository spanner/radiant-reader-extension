require 'sanitize'
require "sanitize/config/generous"

module ReaderHelper
  def standard_gravatar_for(reader=nil, url=nil)
    size = Radiant::Config['forum.gravatar_size'] || 40
    url ||= reader_url(reader)
    gravatar = gravatar_for(reader, {:size => size}, {:class => 'gravatar offset', :width => size, :height => size})
    content_tag(:div, link_to(gravatar, url), :class => "speaker")
  end

  def gravatar_for(reader=nil, gravatar_options={}, img_options ={})
    size = gravatar_options[:size] || 40
    img_options[:size] ||= "#{size}x#{size}"
    gravatar_options[:default] ||= "#{request.protocol}#{request.host_with_port}/images/furniture/no_gravatar.png"
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

  def scrub(text)
    Sanitize.clean(textilize(text))
  end

  def clean(text)
    Sanitize.clean(textilize(text), Sanitize::Config::GENEROUS)
  end

  def truncate_words(text='', length=24, omission="...")
    return '' if text.blank?
    words = text.split
    omission = '' unless words.size > length
    words[0..(length-1)].join(" ") + omission
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
      %{#{t('reader_extension.no')} #{name.pluralize}}
    else      
      name ||= t(list.first.class.to_s.underscore.gsub('_', ' '))
      if total == 1
        %{#{t('reader_extension.showing')} #{t('reader_extension.one')} #{name}}
      elsif list.current_page == 1 && total < list.per_page
        %{#{t('reader_extension.all')} #{total} #{name.pluralize}}
      else
        start = list.offset + 1
        finish = ((list.offset + list.per_page) < list.total_entries) ? list.offset + list.per_page : list.total_entries
        %{#{start} #{t('reader_extension.to')} #{finish} #{t('reader_extension.of')} #{total} #{name.pluralize}}
      end
    end
  end
  
  def message_preview(subject, body, reader)
    preview = <<EOM
From: #{current_user.name} &lt;#{current_user.email}&gt;
To: #{reader.name} &lt;#{reader.email}&gt;
Date: #{Time.now.to_date.to_s :long}
<strong>Subject: #{subject}</strong>

Dear #{reader.name},

#{body}

EOM
  simple_format(preview)
  end

  def choose_page(object, field, select_options={})
    root = Page.respond_to?(:homepage) ? Page.homepage : Page.find_by_parent_id(nil)
    options = page_option_branch(root)
    options.unshift ['<none>', nil]
    select object, field, options, select_options
  end

  def page_option_branch(page, depth=0)
    options = []
    unless page.title.first == '_'
      options << ["#{". " * depth}#{h(page.title)}", page.id]
      page.children.each do |child|
        options += page_option_branch(child, depth + 1)
      end
    end
    options
  end

end
