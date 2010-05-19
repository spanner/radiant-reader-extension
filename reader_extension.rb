require_dependency 'application_controller'

class ReaderExtension < Radiant::Extension
  version "0.83"
  description "Centralises reader/member/user registration and management tasks for the benefit of other extensions"
  url "http://spanner.org/radiant/reader"
  
  define_routes do |map|
    
    map.namespace :admin do |admin|
      admin.resources :readers, :except => [:show]
    end

    map.namespace :admin, :path_prefix => 'admin/readers' do |admin|
      admin.resources :messages, :member => [:preview, :deliver]
    end

    map.resources :readers
    map.resources :messages, :only => [:index, :show], :member => [:preview]

    map.resource :reader_session
    map.resource :reader_activation, :only => [:show, :new]
    map.resource :password_reset
    
    map.repassword '/password_reset/:id/:confirmation_code', :controller => 'password_resets', :action => 'edit'
    map.activate_me '/activate/:id/:activation_code', :controller => 'reader_activations', :action => 'update'
    map.reader_register '/register', :controller => 'readers', :action => 'new'
    map.reader_login '/login', :controller => 'reader_sessions', :action => 'new'
    map.reader_logout '/logout', :controller => 'reader_sessions', :action => 'destroy'
    map.reader_permission_denied '/permission_denied', :controller => 'readers', :action => 'permission_denied'
  end
  
  extension_config do |config|
    config.gem 'authlogic'
    config.gem 'gravtastic'
    config.gem 'sanitize', :source => 'http://gemcutter.org'
    config.gem 'will_paginate', :version => '~> 2.3.11', :source => 'http://gemcutter.org'
    config.extension 'share_layouts'
  end
  
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
    
    # ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag| 
    #   "<span class='field_error'>#{html_tag}</span>" 
    # end 
  end
  
  def deactivate
    admin.tabs.remove "Readers" unless respond_to? :tab
  end
end
