class ReadersDataset < Dataset::Base
  
  def load
    create_reader "Normal"
    create_reader "Idle"
    create_reader "Industrious"
    create_reader "Inactive"
  end
  
  helpers do
    def create_reader(name, attributes={})
      create_record :reader, name.symbolize, reader_attributes(attributes.update(:name => name))
    end
    
    def reader_attributes(attributes={})
      name = attributes[:name] || "John Doe"
      symbol = name.symbolize
      attributes = { 
        :name => name,
        :email => "#{symbol}@spanner.org", 
        :login => symbol.to_s,
        :password => "password"
      }.merge(attributes)
      attributes
    end
    
    def reader_params(attributes={})
      password = attributes[:password] || "password"
      reader_attributes(attributes).update(:password => password, :password_confirmation => password)
    end
    
    def login_as(user)
      login_reader = reader.is_a?(Reader) ? reader : readers(reader)
      flunk "Can't login as non-existing reader #{reader.to_s}." unless login_reader
      request.session['reader_id'] = login_reader.id
      login_reader
    end
    
    def logout
      request.session['reader_id'] = nil
    end
  end
 
end