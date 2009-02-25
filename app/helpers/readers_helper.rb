module ReadersHelper
  
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

  def password_field_with_errors(form, thing, name, options={})
    render :partial => 'password_field', :locals => {
      :form => form,
      :thing => thing,
      :tag => {
        :name => name,
        :symbol => name.intern,
        :fieldid => "#{thing.class.to_s.downcase.underscore}_#{name.downcase}",
        :required => options[:required] || false,
        :class => 'standard',
        :label => name,
        :value => thing.new_record? ? thing.send(name.intern) : '',
        :help => ''
      }.merge(options)
    }
  end
  
  def gravatar_for(reader, gravatar_options={}, img_options ={})
    image_tag reader.gravatar_url(gravatar_options), img_options
  end
  
end
