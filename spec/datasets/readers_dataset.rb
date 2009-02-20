class ReadersDataset < Dataset::Base
  uses :reader_sites
    
  def load
    create_reader "Normal"
    create_reader "Idle"
    create_reader "Activated"
    create_reader "Inactive", :activated_at => nil
    create_reader "Othersite", :site => sites(:yoursite)
  end
  
  helpers do
    def create_reader(name, attributes={})
      attributes = reader_attributes(attributes.update(:name => name))
      reader = create_model Reader, name.symbolize, attributes
    end
    
    def reader_attributes(attributes={})
      name = attributes[:name] || "John Doe"
      symbol = name.symbolize
      attributes = { 
        :name => name,
        :email => "#{symbol}@spanner.org", 
        :password => "password", 
        :password_confirmation => "password",
        :site => sites(:test),
        :activated_at => Time.now.utc
      }.merge(attributes)
      attributes
    end
    
    def reader_params(attributes={})
      password = attributes[:password] || "password"
      reader_attributes(attributes).update(:password => password, :password_confirmation => password)
    end
    
    def login_as_reader(reader)
      login_reader = reader.is_a?(Reader) ? reader : readers(reader)
      request.session['reader_id'] = login_reader.id
      login_reader
    end
    
    def logout_reader
      request.session['reader_id'] = nil
    end
  end
 
end