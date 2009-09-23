class ReaderLayoutsDataset < Dataset::Base
  uses :reader_sites if defined? Site
  
  def load
    create_layout "Main"
    create_layout "Other"
    create_layout "email", :content => %{
<html>
  <head><title><r:title /></title></head>
  <body>
    <p>header</p>
    <r:content />
    <p>footer</p>
  </body>
<html>  
    }
  end
  
  helpers do
    def create_layout(name, attributes={})
      attributes[:site] ||= sites(:test) if Layout.reflect_on_association(:site)
      create_model :layout, name.symbolize, attributes.update(:name => name)
    end
  end
 
end