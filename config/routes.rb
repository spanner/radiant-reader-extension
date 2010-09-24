ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :readers, :except => [:show]
  end

  map.namespace :admin, :path_prefix => 'admin/readers' do |admin|
    admin.resources :messages, :member => [:preview, :deliver]
    admin.resources :reader_settings, :except => [:destroy]
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
