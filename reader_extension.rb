require_dependency 'application_controller'
require 'radiant-reader-extension/version'

class ReaderExtension < Radiant::Extension
  version RadiantReaderExtension::VERSION
  description "Provides reader/member/user registration and management functions"
  url "http://spanner.org/radiant/reader"
  
  extension_config do |config|
    config.gem "json"
    config.gem "authlogic"
    config.gem "oauth"
    config.gem "oauth2"
    config.gem "authlogic-connect"
    config.gem 'sanitize'
  end
  
  migrate_from 'Reader Group', 20110214101339
  
  def activate
    Reader
    ActiveRecord::Base.send :include, GroupedModel                                    # has_group mechanism for any model that can belong_to a group
    ApplicationController.send :include, ControllerExtensions                     # hooks up reader authentication and layout-chooser
    SiteController.send :include, SiteControllerExtensions                            # access control based on group membership
    Page.send :include, GroupedPage                                                   # group associations and visibility decisions
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
      add_item("Reader", "/admin/readers/reader_configuration")
    end
  end
  
  def deactivate

  end
end

module ReaderGroup
  class Exception < StandardError
    def initialize(message = "Sorry: group problem"); super end
  end
  class PermissionDenied < Exception
    def initialize(message = "Sorry: you don't have access to that"); super end
  end
end
