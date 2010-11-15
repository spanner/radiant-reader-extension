require 'sanitize'
module ReaderHelper
  def self.included(base)

    base.module_eval do
      def gravatar_for(reader, gravatar_options={}, img_options ={})
        size = gravatar_options[:size]
        img_options[:size] = "#{size}x#{size}" if size
        image_tag reader.gravatar_url(gravatar_options), img_options
      end

      def clean_textilize(text)
        Sanitize.clean(textilize(text), Sanitize::Config::RELAXED)
      end

      def clean_textilize_without_paragraph(text)
        textiled = clean_textilize(text)
        if textiled[0..2] == "<p>" then textiled = textiled[3..-1] end
        if textiled[-4..-1] == "</p>" then textiled = textiled[0..-5] end
        return textiled
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
    end
  end
end
