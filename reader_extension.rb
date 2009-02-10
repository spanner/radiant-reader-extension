# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class ReaderExtension < Radiant::Extension
  version "0.1"
  description "Centralises user registration and management tasks for the benefit of other extensions"
  url "http://spanner.org/radiant/reader"
  
  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :reader
  #   end
  # end
  
  def activate
    admin.tabs.add "Readers", "/admin/readers", :after => "Layouts", :visibility => [:admin]
  end
  
  def deactivate
    admin.tabs.remove "Readers"
  end
  
end
