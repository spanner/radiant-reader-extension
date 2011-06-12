class Admin::ReadersController < Admin::ResourceController
  helper :reader
  paginate_models
  before_filter :redirect_to_user, :only => :edit

  only_allow_access_to :new, :create, :edit, :update, :remove, :destroy, :settings,
    :when => :admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must be an administrator to add or modify readers'
    
  def create
    model.update_attributes!(params[:reader])
    model.clear_password = params[:reader][:password] if params[:reader] && params[:reader][:password]      # condition is so that radiant tests pass
    model.send_invitation_message
    flash[:notice] = t('reader_extension.reader_saved')
    response_for :create
  end

private

  def redirect_to_user
    if model.is_user?
      redirect_to edit_admin_user_url(model.user)
      return false
    end
    true
  end
  
end