# Uncomment this if you reference any of your controllers in activate
require_dependency 'application_controller'
require 'gravtastic'

class ReaderExtension < Radiant::Extension
  version "0.1"
  description "Centralises reader/member/user registration and management tasks for the benefit of other extensions"
  url "http://spanner.org/radiant/reader"
  
  define_routes do |map|
    
    map.namespace :admin do |admin|
      admin.resources :readers
    end

    map.resources :readers, :member => {:activate => :any, :resend_activation => :any}
    map.resource :reader_session
    map.resource :password_reset
    map.repassword '/password_reset/:id/:confirmation_code', :controller => 'password_resets', :action => 'edit'
    map.activate_me '/activate/:id/:activation_code', :controller => 'readers', :action => 'activate'
    map.reader_login '/login', :controller => 'reader_sessions', :action => 'new'
    map.reader_logout '/logout', :controller => 'reader_sessions', :action => 'destroy'
  end
  
  def activate
    Reader
    ApplicationController.send :include, ControllerExtensions
    UserActionObserver.instance.send :add_observer!, Reader 
    ApplicationHelper.send :include, ReaderHelper
    Site.send :include, ReaderSite if defined? Site
    
    unless defined? admin.reader
      Radiant::AdminUI.send :include, ReaderAdminUI
      admin.reader = Radiant::AdminUI.load_default_reader_regions
      if defined? admin.sites
        admin.sites.edit.add :form, "admin/sites/choose_reader_layout", :after => "edit_homepage"
        admin.readers.index.add :top, "admin/shared/site_jumper"
      end
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
