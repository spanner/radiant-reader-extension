ActionController::Routing::Routes.draw do |map|
  map.namespace :admin, :path_prefix => 'admin/readers' do |admin|
    admin.resources :messages, :member => [:preview, :deliver]
    admin.resources :groups, :has_many => [:memberships, :permissions, :group_invitations, :messages]
    admin.resource :reader_configuration, :controller => 'reader_configuration'
  end

  map.namespace :admin do |admin|
    admin.resources :readers, :except => [:show]
  end

  map.resources :readers, :controller => 'accounts'
  map.resources :messages, :only => [:index, :show], :member => [:preview]
  map.resources :groups, :only => [:index, :show] do |group|
    group.resources :messages, :only => [:index, :show], :member => [:preview]
  end

  map.resource :reader_session
  map.resource :reader_activation, :only => [:show, :new]
  map.resource :password_reset
  
  map.activate_me '/activate/:id/:activation_code', :controller => 'reader_activations', :action => 'update'
  map.repassword_me 'repassword/:id/:confirmation_code', :controller => 'password_resets', :action => 'edit'
  map.reader_register '/register', :controller => 'accounts', :action => 'new'
  map.reader_login '/login', :controller => 'reader_sessions', :action => 'new'
  map.reader_logout '/logout', :controller => 'reader_sessions', :action => 'destroy'
  map.reader_dashboard '/dashboard', :controller => 'accounts', :action => 'dashboard'
  map.reader_account '/account', :controller => 'accounts', :action => 'edit'
  map.reader_profile '/profile', :controller => 'accounts', :action => 'show'
  map.reader_edit_profile '/edit_profile', :controller => 'accounts', :action => 'edit_profile'
  map.reader_permission_denied '/permission_denied', :controller => 'accounts', :action => 'permission_denied'
end
