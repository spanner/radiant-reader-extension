module ReadersHelper
  
  def text_field_with_errors(form, name, args)

  end
  
  def text_area_with_errors(form, name, args)
    
  end

  def field_with_errors(form, name, field)
    
  end
  
  def gravatar_for(reader, gravatar_options={}, img_options ={})
    default_gravatar_options = {
      
    }
    default_img_options = {
      
    }
    image_tag reader.gravatar_url(default_gravatar_options.merge(gravatar_options)), default_img_options.merge(img_options)
  end
  
end
