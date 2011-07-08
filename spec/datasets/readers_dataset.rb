require "authlogic/test_case"
require 'digest/sha1'

class ReadersDataset < Dataset::Base
  uses :users, :pages

  def load
    create_page "People", :slug => "directory", :class_name => 'ReaderPage'
    
    create_reader "Normal"
    create_reader "Another"
    create_reader "Visible"
    create_reader "Ungrouped"
    create_reader "User", :user_id => user_id(:existing)
    create_reader "Inactive", :activated_at => nil

    create_group "Normal"
    create_group "Special"
    create_group "Homed", :homepage_id => page_id(:parent)
    create_group "Elsewhere", :site_id => site_id(:elsewhere) if defined? Site

    create_message "Normal"
    create_message "Grouped", :function_id => "group_welcome"
    create_message "Filtered", :filter_id => 'Textile', :body => 'this is a *filtered* message'
    create_message "Welcome", :filter_id => 'Textile', :body => 'Hi', :function_id => 'welcome'
    create_message "Activation", :filter_id => 'Textile', :body => 'Hi?', :function_id => 'activation'
    create_message "Invitation", :filter_id => 'Textile', :body => 'Hi!', :function_id => 'invitation'
    create_message "Password", :filter_id => 'Textile', :body => 'Oh', :function_id => 'password_reset'
    create_message "Taggy", :filter_id => 'Textile', :body => %{
To <r:recipient:name />

Ying Tong Iddle I Po.

From <r:sender:name />
    }
    
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

    admit_to_group :homed, [readers(:normal)] 
    admit_to_group :normal, [readers(:normal), readers(:inactive)] 
    admit_to_group :special, [readers(:another)] 
    restrict_to_group :homed, [pages(:parent), pages(:childless)]
    restrict_to_group :special, [pages(:news)]
    restrict_to_group :normal, [messages(:grouped)]
  end
  
  helpers do
    def create_reader(name, attributes={})
      reader = create_model Reader, name.symbolize, default_reader_attributes(name).merge(attributes)
    end
    
    def create_group(name, attributes={})
      group = create_record Group, name.symbolize, default_group_attributes(name).merge(attributes)
    end

    def create_message(subject, attributes={})
      message = create_model Message, subject.symbolize, default_message_attributes(subject).merge(attributes)
      message.update_attribute(:created_by, users(:existing)) # otherwise this is blanked by the absence of a current_user, and we need it for preview rendering
    end

    def create_layout(name, attributes={})
      attributes[:site] ||= sites(:test) if Layout.reflect_on_association(:site)
      create_model :layout, name.symbolize, attributes.update(:name => name)
    end

    def default_reader_attributes(name="John Doe")
      symbol = name.symbolize
      attributes = { 
        :name => name,
        :email => "#{symbol}@spanner.org", 
        :login => "#{symbol}@spanner.org",
        :activated_at => Time.now - 1.week,
        :password_salt => "golly",
        :password => 'passw0rd',
        :password_confirmation => 'passw0rd'
      }
      attributes[:site] = sites(:test) if defined? Site
      attributes
    end
        
    def default_group_attributes(name="Group")
      attributes = { 
        :name => name,
        :slug => name.downcase,
        :description => "#{name} group"
      }
      attributes[:site_id] ||= site_id(:test) if defined? Site
      attributes
    end

    def default_message_attributes(subject="Message")
      attributes = { 
        :subject => subject,
        :body => "This is the #{subject} message"
      }
      attributes[:site] = sites(:test) if defined? Site
      attributes
    end

    def login_as_reader(reader)
      activate_authlogic
      login_reader = reader.is_a?(Reader) ? reader : readers(reader)
      ReaderSession.create(login_reader)
      login_reader
    end
    
    def logout_reader
      if session = ReaderSession.find
        session.destroy
      end
    end
    
    def restrict_to_group(g, these)
      g = groups(g) unless g.is_a? Group
      these.each {|thing| thing.permit(g) }
    end
    
    def admit_to_group(g, readers)
      g = groups(g) unless g.is_a? Group
      readers.each {|r| g.admit(r) }
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