require_dependency 'application_controller'
require 'radiant-reader-extension'

class ReaderExtension < Radiant::Extension
  version RadiantReaderExtension::VERSION
  description RadiantReaderExtension::DESCRIPTION
  url RadiantReaderExtension::URL
  
  extension_config do |config|
    config.gem 'authlogic', :version => "~> 2.1.6"
    config.gem 'sanitize', :version => "~> 2.0.1"
    config.gem 'snail', :version => "~> 0.5.5"
    config.gem 'vcard', :version => "~> 0.1.1"
    config.gem 'fastercsv', :version => "~> 1.5.4"
  end
  
  migrate_from 'Reader Group', 20110214101339
  
  def activate
    ActiveRecord::Base.send :include, GroupedModel                                # has_group mechanism for any model that can belong_to a group
    ApplicationController.send :include, ControllerExtensions                     # hooks up reader authentication and layout-chooser
    SiteController.send :include, SiteControllerExtensions                        # access control based on group membership
    Page.send :include, GroupedPage                                               # group associations and visibility decisions
    Site.send :include, ReaderSite if defined? Site                               # adds site scope and site-based layout-chooser
    Page.send :include, ReaderTags                                                # a few mailmerge-like radius tags for use in messages, or for greeting readers on (uncached) pages
    UserActionObserver.instance.send :add_observer!, Reader 
    UserActionObserver.instance.send :add_observer!, Message
    
    unless defined? admin.reader
      Radiant::AdminUI.send :include, ReaderAdminUI
      Radiant::AdminUI.load_reader_extension_regions
    end
    
    admin.page.edit.add :layout, "page_groups"
    
    tab("Readers") do
      add_item("Readers", "/admin/readers")
      add_item("Groups", "/admin/readers/groups")
      add_item("Messages", "/admin/readers/messages")
      add_item("Settings", "/admin/readers/reader_configuration")
    end
    tab("Settings") do
      add_item("Readers", "/admin/readers/reader_configuration")
    end
  end
  
  def deactivate

  end
end

module ReaderError
  class AccessDenied < StandardError
    def initialize(message = "Sorry: you have to log in to see that"); super end
  end
end
