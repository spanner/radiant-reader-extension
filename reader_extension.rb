# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'
require 'gravtastic'

class ReaderExtension < Radiant::Extension
  version "0.1"
  description "Centralises reader/member/user registration and management tasks for the benefit of other extensions"
  url "http://spanner.org/radiant/reader"
  
  define_routes do |map|
    
    map.resources :readers

    map.namespace :admin do |admin|
      admin.resources :readers
    end
    
    map.with_options :controller => 'readers' do |map|
      map.reader_register     'readers/register',                :action => 'new'
      map.reader_login        'readers/login',                   :action => 'login'
      map.reader_logout       'readers/logout',                  :action => 'logout'
      map.reader_self         'readers/me',                      :action => 'me'
      map.reader_activate     '/readers/activate',               :action => 'activate'
      map.reader_reactivate   '/readers/reactivate',             :action => 'reactivate'
      map.reader_password     '/readers/password',               :action => 'password'
    end
    
  end
  
  def activate
    ApplicationController.send :include, ReaderLoginSystem
    Radiant::AdminUI.send :include, ReaderAdminUI         # UI is an instance and already loaded, and this doesn't get there in time. so:
    Radiant::AdminUI.instance.reader = Radiant::AdminUI.load_default_reader_regions
    Radiant::Config['readers.layout'] = "Main"
    if defined? MultiSiteExtension
      Radiant::Config['readers.site_based'] = true 
      Site.send :include, ReaderSiteExtension
    else
      Radiant::Config['readers.site_based'] = false 
    end
    admin.tabs.add "Readers", "/admin/readers", :after => "Layouts", :visibility => [:admin]
  end
  
  def deactivate
    admin.tabs.remove "Readers"
  end
  
end
