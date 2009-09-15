class ReaderActionController < ApplicationController
  
  no_login_required
  before_filter :set_reader_for_user
  before_filter :set_site_title
  
  before_filter :require_reader, :except => [:index, :show]
  helper_method :current_site, :current_site=, :logged_in?, :logged_in_user?, :logged_in_admin?
  
  radiant_layout { |controller| controller.layout_for :reader }

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

protected
  
  # context-setters
    
  def set_reader_for_user
    if current_user
      @current_reader_session = ReaderSession.create!(Reader.find_or_create_for_user(current_user))
    end
  end

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
    if current_reader
      Reader.current = current_reader
    else
      store_location
      respond_to do |format|
        format.html { redirect_to reader_login_url }
        format.js { render :partial => 'reader_sessions/login_form' }
      end
      return false
    end
  end

  def require_no_reader
    if current_reader
      store_location
      flash[:notice] = "Please log out first"
      redirect_back_or_to url_for(current_reader)
      return false
    end
  end

  def store_location(location = request.request_uri)
    session[:return_to] = location
  end

  # generic responses

  def redirect_back_or_to(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def redirect_back_with_format(format = 'html')
    address = session[:return_to]
    raise StandardError, "Can't add format to an already formatted url: #{address}" unless File.extname(address).blank?
    redirect_to address + ".#{format}"    # nasty!
  end
  
  def render_page_or_feed(template_name = action_name)
    respond_to do |format|
      format.html { render :action => template_name }
      format.rss  { render :action => template_name, :layout => 'feed' }
      format.js  { render :action => template_name, :layout => false }
    end
  end
  
end
