require_dependency 'application_controller'

class ReaderExtension < Radiant::Extension
  version "1.3.0"
  description "Provides reader/member/user registration and management functions"
  url "http://spanner.org/radiant/reader"
  
  extension_config do |config|
    config.gem 'authlogic'
    config.gem 'sanitize'
  end
  
  def activate
    Reader
    ApplicationController.send :include, ControllerExtensions                     # hooks up reader authentication and layout-chooser
    Site.send :include, ReaderSite if defined? Site                               # adds site scope and site-based layout-chooser
    Page.send :include, ReaderTags                                                # a few mailmerge-like radius tags for use in messages, or for greeting readers on (uncached) pages
    UserActionObserver.instance.send :add_observer!, Reader 
    UserActionObserver.instance.send :add_observer!, Message
    
    unless defined? admin.reader
      Radiant::AdminUI.send :include, ReaderAdminUI
      Radiant::AdminUI.load_reader_extension_regions
    end
        
    if respond_to?(:tab)
      tab("Readers") do
        add_item("Readers", "/admin/readers")
        add_item("Messages", "/admin/readers/messages")
        add_item("Settings", "/admin/readers/reader_configuration")
      end
      tab("Settings") do
        add_item("Reader", "/admin/readers/reader_configuration")
      end
    else
      admin.tabs.add "Readers", "/admin/readers", :after => "Layouts", :visibility => [:all]
      if admin.tabs['Readers'].respond_to?(:add_link)
        admin.tabs['Readers'].add_link('readers', '/admin/readers')
        admin.tabs['Readers'].add_link('messages', '/admin/readers/messages')
        admin.tabs['Readers'].add_link('settings', '/admin/readers/reader_configuration')
      end
    end
  end
  
  def deactivate
    admin.tabs.remove "Readers" unless respond_to? :tab
  end
end
