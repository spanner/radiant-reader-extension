class ReaderActionController < ApplicationController
  include Radiant::Pagination::Controller

  helper :reader
  helper_method :current_site, :current_site=, :logged_in?, :logged_in_user?, :logged_in_admin?
  
  no_login_required
  
  # reader session is normally required for modifying actions
  before_filter :require_reader, :except => [:index, :show]
  
  radiant_layout { |controller| Radiant::Config['reader.layout'] }

  # authorisation helpers

  def logged_in?
    true if current_reader
  end

  def logged_in_user?
    true if logged_in? && current_reader.is_user?
  end

  def logged_in_admin?
    true if logged_in_user? && current_reader.admin?
  end

  def permission_denied
    session[:return_to] ||= request.referer
    @title = flash[:error] || t('reader_extension.permission_denied')
    render
  end
  
  def default_welcome_url(reader=nil)
    (reader && reader.home_url) || reader_dashboard_url
  end

protected
  
  # NB. ReaderError exceptions are caught in ApplicationController rescue_froms
    
  def require_reader
    unless set_reader     # set_reader is added to ApplicationController and sets Reader.current while checking authentication
      store_location
      raise ReaderError::LoginRequired, t('reader_extension.please_log_in')
      false
    end
  end
  
  def require_activated_reader
    unless current_reader && current_reader.activated?
      raise ReaderError::ActivationRequired, t('reader_extension.activation_required')
      false
    end
  end

  def require_no_reader
    if set_reader
      store_location
      flash[:notice] = t('reader_extension.please_log_out')
      redirect_back_or_to url_for(current_reader)
      return false
    end
  end
  
end
