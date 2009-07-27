module ControllerExtensions    # for inclusion into ApplicationController

  def self.included(base)
    
    base.class_eval do
      helper_method :current_reader_session, :current_reader, :current_reader=, :logged_in?, :logged_in_user?, :logged_in_admin?
    end

    # returns a layout name for processing by radiant_layout
    # eg:
    # radiant_layout { |controller| controller.layout_for :forum }
    # will try these possibilities in order:
    #   current_site.forum_layout
    #   current_site.reader_layout
    #   Radiant::Config["forum.layout"]
    #   Radiant::Config["reader.layout"]
    #   a layout called 'Main'
    #   the first layout it can find
  
    def layout_for(area = :reader)
      logger.warn "*** layout_for(#{area})"
      if defined? Site && current_site && current_site.respond_to?(:layout_for)
        current_site.layout_for(area)
      elsif default_layout = Radiant::Config["#{area}.layout"]
        default_layout
      elsif reader_layout = Radiant::Config["reader.layout"]
        reader_layout
      elsif main_layout = Layout.find_by_name('Main')
        "Main"
      elsif any_layout = Layout.find(:first)
        any_layout.name
      end
    end

    # reader authentication helpers

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

    def current_reader_session
      return @current_reader_session if defined?(@current_reader_session)
      @current_reader_session = ReaderSession.find
      @current_reader_session
    end
    
    def current_reader_session=(reader_session)
      @current_reader_session = reader_session
    end

    def current_reader
      return @current_reader if defined?(@current_reader)
      @current_reader = current_reader_session.record if current_reader_session
    end
    
    def current_reader=(reader)
      current_reader_session = ReaderSession.create(reader)
      @current_reader = reader
    end

    # before_filters

    def require_reader
      if current_reader
        Reader.current = current_reader
      else
        store_location
        flash[:notice] = "Please log in"
        redirect_to reader_login_url
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

    def store_location
      session[:return_to] = request.request_uri
    end

    # generic responses

    def redirect_back_or_to(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

  end
end







