require_dependency 'application_controller'
require 'radiant-reader-extension'

class ReaderExtension < Radiant::Extension
  version RadiantReaderExtension::VERSION
  description RadiantReaderExtension::DESCRIPTION
  url RadiantReaderExtension::URL
  
  migrate_from 'Reader Group', 20110214101339
  
  def activate
    ActiveRecord::Base.send :include, GroupedModel                                # has_group mechanism for any model that can belong_to a group
    ApplicationController.send :include, ControllerExtensions                     # hooks up reader authentication and layout-chooser
    SiteController.send :include, SiteControllerExtensions                        # access control based on group membership
    User.send :include, ReaderUser                                                # update linked reader when user account values change
    Page.send :include, GroupedPage                                               # group associations and visibility decisions
    RailsPage.send :include, GroupedRailsPage                                     # some control over the caching of ShareLayouts pages
    # Site.send :include, ReaderSite if defined? Site                             # adds site scope and site-based layout-chooser
    Page.send :include, ReaderTags                                                # a few mailmerge-like radius tags for use in messages, or for greeting readers on (uncached) pages
    UserActionObserver.instance.send :add_observer!, Reader 
    UserActionObserver.instance.send :add_observer!, Message
    
    unless defined? admin.reader
      Radiant::AdminUI.send :include, ReaderAdminUI
      Radiant::AdminUI.load_reader_extension_regions
    end
    
    admin.page.edit.add :layout, "admin/groups/edit_access"
    admin.page.edit.add :main, "admin/groups/popup", :after => 'edit_popups'
    admin.page.index.add :sitemap_head, "groups_column_header", :after => 'status_column_header'
    admin.page.index.add :node, "groups_column", :after => 'status_column'
    
    tab("Readers") do
      add_item("Readers", "/admin/readers")
      add_item("Groups", "/admin/readers/groups")
      add_item("Messages", "/admin/readers/messages")
      add_item("Settings", "/admin/reader_settings")
    end
    tab("Settings") do
      add_item("Readers", "/admin/reader_settings")
    end
  end
end

module ReaderError
  class LoginRequired < StandardError
    def initialize(message = "Login Required"); super end
  end
  class ActivationRequired < StandardError
    def initialize(message = "Activation Required"); super end
  end
  class AccessDenied < StandardError
    def initialize(message = "Access Denied"); super end
  end
end
