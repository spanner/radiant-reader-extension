module ControllerExtensions    # for inclusion into ApplicationController

  def self.included(base)
    
    base.class_eval do
      before_filter :set_reader_for_user
      before_filter :set_reader
      helper_method :current_reader_session, :current_reader, :current_reader=
    end

  protected

    def current_reader_session
      return @current_reader_session if @current_reader_session.is_a?(ReaderSession)
      @current_reader_session = ReaderSession.find
      Reader.current = @current_reader_session.record if @current_reader_session
      @current_reader_session
    end

    def current_reader_session=(reader_session)
      @current_reader_session = reader_session
    end

    def current_reader
      current_reader_session.record if current_reader_session
    end

    def current_reader=(reader)
      if reader && reader.is_a?(Reader)
        current_reader_session = ReaderSession.create!(reader)
      else
        current_reader_session.destroy
      end
    end
    
    def set_reader_for_user
      if current_user
        current_reader_session = ReaderSession.create!(Reader.find_or_create_for_user(current_user))
      end
    end

    def set_reader
      Reader.current = current_reader
    end

    def store_location(location = request.request_uri)
      session[:return_to] = location
    end

    def redirect_back_or_to(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def redirect_back_with_format(format = 'html')
      address = session[:return_to]
      raise StandardError, "Can't add format to an already formatted url: #{address}" unless File.extname(address).blank?
      redirect_to address + ".#{format}"    # nasty! but necessary for inline login.
    end

    def render_page_or_feed(template_name = action_name)
      respond_to do |format|
        format.html { render :action => template_name }
        format.rss  { render :action => template_name, :layout => 'feed' }
        format.js  { render :action => template_name, :layout => false }
      end
    end

  end
end







