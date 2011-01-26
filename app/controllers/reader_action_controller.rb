class ReaderActionController < ApplicationController
  include Radiant::Pagination::Controller

  helper :reader
  helper_method :current_site, :current_site=, :logged_in?, :logged_in_user?, :logged_in_admin?

  attr_accessor :css, :js
  helper_method :reader_css_paths, :reader_js_paths, :add_reader_js, :add_reader_css
  
  no_login_required
  before_filter :set_site_title
  
  # reader session is normally required for modifying actions
  before_filter :require_reader, :except => [:index, :show]
  
  radiant_layout { |controller| Radiant::Config['reader.layout'] }

  # allow reader-based extensions to contribute to the public interface
  # these methods can be called from any view

  def add_reader_css(path)
    @css ||= []
    @css << path
  end

  def add_reader_js(path)
    @js ||= []
    @js << path
  end

  # these methods are called from :reader_css and :reader_js page parts defined in view/readers/_standard_parts

  def reader_css_paths
    @css ||= []
    @css.uniq
  end
  
  def reader_js_paths
    @js ||= []
    @js.uniq
  end
  
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
    @title = flash[:error] || t('permission_denied')
    render
  end

protected
  
  # context-setters

  def set_site_title
    if defined? Site && current_site
      @site_title = current_site.name
      @short_site_title = current_site.abbreviation || @site_title
      @site_url = current_site.base_domain
    else
      @site_title = Radiant::Config['site.title']
      @short_site_title = Radiant::Config['site.abbreviation'] || @site_title
      @site_url = request.host
    end
  end

  def require_reader
    unless set_reader     # set_reader is in ControllerExtension and sets Reader.current while checking for current_reader
      store_location
      respond_to do |format|
        format.html {
          flash[:explanation] = t('reader_required')
          flash[:notice] = t('please_log_in')
          redirect_to reader_login_url 
        }
        format.js { 
          @inline = true
          render :partial => 'reader_sessions/login_form' 
        }
      end
      false
    end
  end
  
  def require_activated_reader
    unless current_reader && current_reader.activated?
      respond_to do |format|
        format.html { 
          flash[:explanation] = t('activation_required')
          redirect_to reader_activation_url 
        }
        format.js { 
          @inline = true
          render :partial => 'reader_activations/activation_required' 
        }
      end
      false
    end
  end

  def require_no_reader
    if set_reader
      store_location
      flash[:notice] = t('please_log_out')
      redirect_back_or_to url_for(current_reader)
      return false
    end
  end
  
end
