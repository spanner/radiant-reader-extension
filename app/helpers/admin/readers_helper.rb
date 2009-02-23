module Admin
  module ReadersHelper  
    def gravatar_for(reader, gravatar_options={}, img_options ={})
      image_tag reader.gravatar_url(gravatar_options), img_options
    end
  end
end