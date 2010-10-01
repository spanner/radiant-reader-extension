require_dependency 'application_controller'

class ReaderExtension < Radiant::Extension
  version "0.9.2"
  description "Provides reader/member/user registration and management functions"
  url "http://spanner.org/radiant/reader"
  
  extension_config do |config|
    config.gem 'authlogic'
    config.gem 'sanitize'
    config.gem 'will_paginate'
  end
  
  def activate
    Reader
    ApplicationController.send :include, ControllerExtensions                     # hooks up reader authentication and layout-chooser
    ApplicationHelper.send :include, ReaderHelper                                 # display usefulness including error-wrapper
    Site.send :include, ReaderSite if defined? Site                               # adds site scope and site-based layout-chooser
    Page.send :include, ReaderTags                                                # a few mailmerge-like radius tags for use in messages, or for greeting readers on (uncached) pages
    Radiant::Config.send :include, ConfigExtensions                                # .boolean?
    UserActionObserver.instance.send :add_observer!, Reader 
    UserActionObserver.instance.send :add_observer!, Message
    
    unless defined? admin.reader
      Radiant::AdminUI.send :include, ReaderAdminUI
      Radiant::AdminUI.load_reader_extension_regions
      admin.reader = Radiant::AdminUI.load_default_reader_regions
      admin.message = Radiant::AdminUI.load_default_message_regions
      admin.reader_setting = Radiant::AdminUI.load_default_reader_setting_regions
      if defined? admin.sites
        admin.sites.edit.add :form, "admin/sites/choose_reader_layout", :after => "edit_homepage"
      end
    end
    
    if respond_to?(:tab)
      tab("Readers") do
        add_item("Readers", "/admin/readers")
        add_item("Settings", "/admin/readers/reader_settings")
      end
      tab("Settings") do
        add_item("Reader", "/admin/readers/reader_settings")
      end
    else
      admin.tabs.add "Readers", "/admin/readers", :after => "Layouts", :visibility => [:all]
      if admin.tabs['Readers'].respond_to?(:add_link)
        admin.tabs['Readers'].add_link('readers', '/admin/readers')
        admin.tabs['Readers'].add_link('settings', '/admin/readers/reader_settings')
      end
    end
  end
  
  def deactivate
    admin.tabs.remove "Readers" unless respond_to? :tab
  end
end
