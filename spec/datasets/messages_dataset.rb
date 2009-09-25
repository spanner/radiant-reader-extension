class MessagesDataset < Dataset::Base
  datasets = [:readers, :users]
  datasets << :reader_sites if defined? Site
  uses *datasets

  def load
    create_message "Normal"
    create_message "Filtered", :filter_id => 'Textile', :body => 'this is a *filtered* message'
    create_message "Welcome", :filter_id => 'Textile', :body => 'Hi', :function => 'welcome'
    create_message "Activation", :filter_id => 'Textile', :body => 'Hi?', :function => 'activation'
    create_message "Invitation", :filter_id => 'Textile', :body => 'Hi!', :function => 'invitation'
    create_message "Password", :filter_id => 'Textile', :body => 'Oh', :function => 'password_reset'
    create_message "Taggy", :filter_id => 'Textile', :body => %{
To <r:recipient:name />

Ying Tong Iddle I Po.

From <r:sender:name />
    }
  end
  
  helpers do
    def create_message(subject, attributes={})
      attributes = message_attributes(attributes.update(:subject => subject))
      message = create_model Message, subject.symbolize, attributes
      message.update_attribute(:created_by, users(:existing))
    end
    
    def message_attributes(attributes={})
      subject = attributes[:subject] || "Message"
      symbol = subject.symbolize
      attributes = { 
        :subject => subject,
        :body => "This is the #{subject} message"
      }.merge(attributes)
      attributes[:site] = sites(:test) if defined? Site
      attributes
    end
    
    def seem_to_send(message, reader)
      message = messages(message) unless message.is_a?(Message)
      reader = readers(reader) unless reader.is_a?(Reader)
      sending = MessageReader.find_or_create_by_message_id_and_reader_id(message.id, reader.id)
      sending.sent_at = 10.minutes.ago
      sending.save
    end
  end
 
end