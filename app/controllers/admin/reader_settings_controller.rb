class Admin::ReaderSettingsController < ApplicationController
  before_filter :require_admin
  before_filter :get_setting, :only => [:show, :edit, :update]
  cattr_accessor :settable
  # this will need to be extensible
  @@settable = ['reader.allow_registration?', 'reader.require_confirmation?', 'reader.layout', 'site.title', 'site.url', 'email.from_address', 'email.from_name']

  def index
    
  end
  
  def show
    respond_to do |format|
      format.html { }
      format.js { render :layout => false }
    end
  end
  
  def edit
    respond_to do |format|
      format.html { }
      format.js { render :layout => false }
    end
  end
  
  def update
    @setting.value = params[:radiant_config][:value]
    @setting.save!
    respond_to do |format|
      format.html { render :action => 'show' }
      format.js { render :layout => false, :action => 'show' }
    end
  end

private

  def settable?(key)
    self.class.settable.include?(key)
  end

  def get_setting
    @setting = Radiant::Config.find(params[:id])
    unless settable?(@setting.key)
      flash[:error] = "Unknown key"
    end
  end

  def require_admin
    unless current_user.admin?
      flash[:error] = 'Only administrators can change reader settings'
      redirect to :action => :index
    end
  end
  
end