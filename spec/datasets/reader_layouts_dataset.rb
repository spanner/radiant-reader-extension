class ReaderLayoutsDataset < Dataset::Base
  
  def load
    create_layout "Main"
    create_layout "Other"
  end
  
  helpers do
    def create_layout(name, attributes={})
      attributes[:site] ||= sites(:test) if Layout.reflect_on_association(:site)
      create_model :layout, name.symbolize, attributes.update(:name => name)
    end
  end
 
end