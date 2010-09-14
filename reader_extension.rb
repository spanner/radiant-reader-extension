require_dependency 'application_controller'

class ReaderExtension < Radiant::Extension
  version "0.9.0"
  description "Centralises reader/member/user registration and management tasks for the benefit of other extensions"
  url "http://spanner.org/radiant/reader"
  
  def activate
    Reader
    ApplicationController.send :include, ControllerExtensions                     # hooks up reader authentication and layout-chooser
    ApplicationHelper.send :include, ReaderHelper                                 # display usefulness including error-wrapper
    Site.send :include, ReaderSite if defined? Site                               # adds site scope and site-based layout-chooser
    Page.send :include, ReaderTags                                                # a few mailmerge-like radius tags for use in messages, or for greeting readers on (uncached) pages

    UserActionObserver.instance.send :add_observer!, Reader 
    UserActionObserver.instance.send :add_observer!, Message
    
    unless defined? admin.reader
      Radiant::AdminUI.send :include, ReaderAdminUI
      admin.reader = Radiant::AdminUI.load_default_reader_regions
      admin.message = Radiant::AdminUI.load_default_message_regions
      if defined? admin.sites
        admin.sites.edit.add :form, "admin/sites/choose_reader_layout", :after => "edit_homepage"
      end
    end
    
    if respond_to?(:tab)
      tab("Readers") do
        add_item("Reader list", "/admin/readers")
        add_item "Invite reader", "/admin/readers/new"
        add_item "Messages", "/admin/readers/messages"
        add_item "New message", "/admin/readers/messages/new"
      end
    else
      admin.tabs.add "Readers", "/admin/readers", :after => "Layouts", :visibility => [:all]
      if admin.tabs['Readers'].respond_to?(:add_link)
        admin.tabs['Readers'].add_link('readers', '/admin/readers')
        admin.tabs['Readers'].add_link('messages', '/admin/readers/messages')
      end
    end
  end
  
  def deactivate
    admin.tabs.remove "Readers" unless respond_to? :tab
  end
end
