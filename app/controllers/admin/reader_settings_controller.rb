class Admin::ReaderSettingsController < ApplicationController
  before_filter :require_admin
  before_filter :get_setting, :only => [:show, :edit, :update]
  cattr_accessor :settable
  # this will need to be extensible
  @@settable = ['reader.allow_registration?', 'reader.require_confirmation?', 'reader.layout', 'site.title', 'site.url', 'email.from_address', 'email.from_name']

  def self.make_settable(*keys)
    @@settable += keys
  end

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
    @setting.value = params[:value] || params[:radiant_config][:value]
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
      respond_to do |format|
        format.html { 
          flash['error'] = "Not settable"
          redirect_to :action => 'index'
        }
        format.js { render :status => 403, :text => 'Not settable' }
      end
      return false
    end
  end

  def require_admin
    unless current_user.admin?
      flash[:error] = 'Only administrators can change reader settings'
      respond_to do |format|
        format.html { 
          flash['error'] = "Admin required"
          redirect_to :action => 'index'
        }
        format.js { render :status => 403, :text => 'Admin required' }
      end
      return false
    end
  end
  
end