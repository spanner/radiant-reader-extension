class ReaderLayoutsDataset < Dataset::Base
  
  def load
    create_layout "Main"
    create_layout "Other"
  end
  
  helpers do
    def create_layout(name, attributes={})
      create_record :layout, name.symbolize, attributes.update(:name => name)
    end
  end
 
end