ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :readers, :except => [:show]
    admin.resource :reader_settings, :controller => 'reader_configuration'
  end

  map.namespace :admin, :path_prefix => 'admin/readers' do |admin|
    admin.resources :messages, :member => [:preview, :deliver]
    admin.resources :groups, :has_many => [:memberships, :permissions, :group_invitations, :messages]
    admin.resources :memberships, :only => [:edit, :update], :member => [:toggle]
    admin.resources :permissions, :only => [], :member => [:toggle]
  end

  readers_prefix = Radiant.config['reader.profiles_path'] || "directory"

  map.resources :readers, :controller => 'accounts', :path_prefix => readers_prefix
  map.resources :messages, :only => [:index, :show], :member => [:preview], :path_prefix => readers_prefix
  map.resources :groups, :path_prefix => readers_prefix do |group|
    group.resources :messages, :only => [:index, :show], :member => [:preview]
  end

  accounts_prefix = Radiant.config['reader.preferences_path'] || "account"

  map.resource :reader_session, :path_prefix => accounts_prefix
  map.resource :reader_activation, :only => [:show, :new], :path_prefix => accounts_prefix
  map.resource :password_reset, :path_prefix => accounts_prefix

  map.activate_me "#{accounts_prefix}/activate/:id/:activation_code", :controller => 'reader_activations', :action => 'update'
  map.repassword_me "#{accounts_prefix}/repassword/:id/:confirmation_code", :controller => 'password_resets', :action => 'edit'
  map.reader_register "#{accounts_prefix}/register", :controller => 'accounts', :action => 'new'
  map.reader_login "#{accounts_prefix}/login", :controller => 'reader_sessions', :action => 'new'
  map.reader_logout "#{accounts_prefix}/logout", :controller => 'reader_sessions', :action => 'destroy'
  map.reader_account "#{accounts_prefix}/preferences", :controller => 'accounts', :action => 'edit'
  map.reader_profile "#{readers_prefix}/profile", :controller => 'accounts', :action => 'show'
  map.reader_edit_profile "#{accounts_prefix}/edit_profile", :controller => 'accounts', :action => 'edit_profile'
  map.reader_permission_denied "#{accounts_prefix}/permission_denied", :controller => 'accounts', :action => 'permission_denied'
  
  map.reader_index readers_prefix, :controller => 'accounts', :action => 'index'
  map.reader_dashboard accounts_prefix, :controller => 'accounts', :action => 'dashboard'

end
