module ReadersHelper
  
  def text_field_with_errors(form, name, args)

  end
  
  def text_area_with_errors(form, name, args)
    
  end

  def field_with_errors(form, name, field)
    
  end
  
  def gravatar_for(reader, gravatar_options={}, img_options ={})
    image_tag reader.gravatar_url(gravatar_options), img_options
  end
  
end
