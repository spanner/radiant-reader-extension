module ReaderHelper
  def self.included(base)

    base.module_eval do

      def text_field_with_errors(form, thing, name, options={})
        field_with_errors(form, thing, name, 'text', options)
      end
  
      def text_area_with_errors(form, thing, name, options={})
        field_with_errors(form, thing, name, 'text_area', {:rows => 8}.merge(options))
      end
  
      def field_with_errors(form, thing, name, type, options={})
        render :partial => 'field', :locals => {
          :form => form,
          :thing => thing,
          :tag => {
            :type => type,
            :name => name,
            :symbol => name.intern,
            :fieldid => "#{thing.class.to_s.downcase.underscore}_#{name.downcase}",
            :required => options[:required] || false,
            :class => 'standard',
            :label => name,
            :help => ''
          }.merge(options)
        }
      end
  
      def gravatar_for(reader, gravatar_options={}, img_options ={})
        image_tag reader.gravatar_url(gravatar_options), img_options
      end

      def clean_textilize(text)
          white_list(textilize(text))   # two step so simple user-input html works too
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
