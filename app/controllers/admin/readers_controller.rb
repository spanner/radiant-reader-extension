class Admin::ReadersController < Admin::ResourceController

  only_allow_access_to :new, :create, :edit, :update, :remove, :destroy,
    :when => :admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must be an administrator to add or modify readers.'
  
  def create
    model.update_attributes!(params[:reader])
    model.current_password = params[:reader][:password]
    model.send_invitation_message
    announce_saved
    response_for :create
  end
  
end