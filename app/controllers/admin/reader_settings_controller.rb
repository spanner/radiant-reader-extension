class Admin::ReaderSettingsController < ApplicationController
  only_allow_access_to :show, :edit, :update,
    :when => [:admin],
    :denied_url => { :controller => 'admin/reader_settings', :action => 'index' },
    :denied_message => 'You must have admin privileges to edit reader settings.'
  
  before_filter :default_settings
  before_filter :get_setting, :only => [:show, :edit, :update]
  
  cattr_accessor :settable
  # this will need to be extensible
  @@settable = {
    'reader.allow_registration?' => true,
    'reader.require_confirmation?' => true,
    'reader.layout' => '',
    'site.title' => 'Site Title',
    'site.url' => 'Site URL', 
    'reader.mail_from_name' => 'Sender', 
    'reader.mail_from_address' => 'sender@example.com'
  }

  def self.make_settable(settings)
    @@settable.merge! settings
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
    self.class.settable.keys.include?(key)
  end

  # temporarily while I do this properly in radiant
  
  def default_settings
    self.class.settable.each do |k, v|
      Radiant::Config[k] ||= v
    end
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
  
end