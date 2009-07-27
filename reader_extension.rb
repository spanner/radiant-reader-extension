# Uncomment this if you reference any of your controllers in activate
require_dependency 'application_controller'
require 'gravtastic'

class ReaderExtension < Radiant::Extension
  version "0.1"
  description "Centralises reader/member/user registration and management tasks for the benefit of other extensions"
  url "http://spanner.org/radiant/reader"
  
  define_routes do |map|
    
    map.resources :readers, :member => {:activate => :any}
    map.resource :reader_session
    map.resource :password_reset
    map.repassword '/password_reset/:id/:confirmation_code', :controller => 'password_resets', :action => 'edit'
    map.activate_reader '/activate/:id/:activation_code', :controller => 'readers', :action => 'activate'
    map.reader_login '/login', :controller => 'reader_sessions', :action => 'new'
    map.reader_logout '/logout', :controller => 'reader_sessions', :action => 'destroy'
    map.namespace :admin do |admin|
      admin.resources :readers
    end
  end
  
  def activate
    ApplicationController.send :include, ControllerExtensions
    Radiant::AdminUI.send :include, ReaderAdminUI unless defined? admin.reader
    admin.reader = Radiant::AdminUI.load_default_reader_regions
    UserActionObserver.instance.send :add_observer!, Reader 

    ApplicationHelper.send :include, ReaderHelper
    
    if defined? Site && defined? ActiveRecord::SiteNotFound       # currently we know it's the spanner multi_site if ActiveRecord::SiteNotFound is defined
      Site.send :include, ReaderSite
      admin.sites.edit.add :form, "admin/sites/choose_reader_layout", :after => "edit_homepage"
      admin.readers.index.add :top, "admin/shared/site_jumper"
    end
    
    admin.tabs.add "Readers", "/admin/readers", :after => "Layouts", :visibility => [:all]
    
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag| 
      "<span class='field_error'>#{html_tag}</span>" 
    end 
  end
  
  def deactivate
    admin.tabs.remove "Readers"
  end
end
