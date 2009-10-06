require_dependency 'application_controller'

class ReaderExtension < Radiant::Extension
  version "0.8"
  description "Centralises reader/member/user registration and management tasks for the benefit of other extensions"
  url "http://spanner.org/radiant/reader"
  
  define_routes do |map|
    
    map.namespace :admin do |admin|
      admin.resources :readers, :except => [:show]
    end

    map.namespace :admin, :path_prefix => 'admin/readers' do |admin|
      admin.resources :messages, :member => [:preview, :deliver]
    end

    map.resources :readers, :member => {:activate => :any, :resend_activation => :any}
    map.resources :messages, :only => [:index, :show], :member => [:preview]

    map.resource :reader_session
    map.resource :password_reset
    map.repassword '/password_reset/:id/:confirmation_code', :controller => 'password_resets', :action => 'edit'
    map.activate_me '/activate/:id/:activation_code', :controller => 'readers', :action => 'activate'
    map.reader_login '/login', :controller => 'reader_sessions', :action => 'new'
    map.reader_logout '/logout', :controller => 'reader_sessions', :action => 'destroy'
    map.reader_permission_denied '/permission_denied', :controller => 'readers', :action => 'permission_denied'
  end
  
  extension_config do |config|
    config.gem 'authlogic'
    config.gem 'gravtastic'
    config.extension 'share_layouts'
    config.extension 'submenu'
  end
  
  def activate
    Reader
    ApplicationController.send :include, ControllerExtensions                     # hooks up reader authentication and layout-chooser
    ApplicationHelper.send :include, ReaderHelper                                 # display usefulness including error-wrapper
    Site.send :include, ReaderSite if defined? Site                               # adds site scope and site-based layout-chooser
    Page.send :include, MessageTags                                               # a few mailmerge-like radius tags for use in messages

    UserActionObserver.instance.send :add_observer!, Reader 
    UserActionObserver.instance.send :add_observer!, Message
    
    unless defined? admin.reader
      Radiant::AdminUI.send :include, ReaderAdminUI
      admin.reader = Radiant::AdminUI.load_default_reader_regions
      admin.message = Radiant::AdminUI.load_default_message_regions
      if defined? admin.sites
        admin.sites.edit.add :form, "admin/sites/choose_reader_layout", :after => "edit_homepage"
        admin.readers.index.add :top, "admin/shared/site_jumper"
      end
    end
    
    admin.tabs.add "Readers", "/admin/readers", :after => "Layouts", :visibility => [:all]
    admin.tabs['Readers'].add_link('readers', '/admin/readers')
    admin.tabs['Readers'].add_link('messages', '/admin/readers/messages')
    
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag| 
      "<span class='field_error'>#{html_tag}</span>" 
    end 
  end
  
  def deactivate
    admin.tabs.remove "Readers"
  end
end
