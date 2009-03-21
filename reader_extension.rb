# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'
require 'gravtastic'

class ReaderExtension < Radiant::Extension
  version "0.1"
  description "Centralises reader/member/user registration and management tasks for the benefit of other extensions"
  url "http://spanner.org/radiant/reader"
  
  define_routes do |map|
    
    map.with_options :controller => 'readers' do |map|
      map.reader_register       'readers/register',                :action => 'new'
      map.reader_login          'readers/login',                   :action => 'login'
      map.reader_logout         'readers/logout',                  :action => 'logout'
      map.reader_self           'me',                              :action => 'me'
      map.reader_edit_self      'me/edit',                         :action => 'edit'
      map.reader_activate       '/readers/activate',               :action => 'activate'
      map.reader_reactivate     '/readers/reactivate',             :action => 'reactivate'
      map.reader_password       '/readers/password',               :action => 'password'
      map.reader_repassword     '/users/:id/repassword/:activation_code', :action => 'repassword'
      map.reader_auto_activate  '/activate/:id/:activation_code', :action => 'activate'
    end

    map.resources :readers
    
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :readers
    end
  end
  
  def activate
    ActiveRecord::Base.send :include, ModelExtensions
    ApplicationController.send :include, ControllerExtensions
    ApplicationController.send :include, ReaderLoginSystem

    Radiant::AdminUI.send :include, ReaderAdminUI unless defined? admin.reader
    admin.reader = Radiant::AdminUI.load_default_reader_regions
    UserActionObserver.instance.send :add_observer!, Reader 

    ApplicationHelper.send :include, ReaderHelper
    
    if defined? Site && admin.sites       # currently we know it's the spanner multi_site if admin.sites is defined
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
