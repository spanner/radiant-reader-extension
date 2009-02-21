module ReaderLoginSystem

  def self.included(base)
    base.class_eval %{
      helper_method :current_reader
      before_filter :set_current_reader
      alias_method_chain :login_from_cookie, :readers
      alias_method_chain :set_session_cookie, :readers
    } 
    base.extend ClassMethods
    super
  end

  def find_readers_layout
    if current_site
      current_site.reader_layout_or_default
    elsif default_layout = Radiant::Config['reader.layout']
      default_layout
    elsif any_layout = Layout.find(:first)
      any_layout.name
    end
  end

  # this should all look familiar

  protected
    
    def current_reader
      @current_reader ||= Reader.find(session['reader_id']) rescue nil
    end
    
    def current_reader=(value=nil)
      if value && value.is_a?(Reader)
        @current_reader = value
        session['reader_id'] = value.id 
      else
        @current_reader = nil
        session['reader_id'] = nil
      end
      @current_reader
    end

    def authenticate_reader
      login_from_cookie
      if current_reader
        true
      else
        respond_to do |format|
          format.html { 
            session[:return_to] = request.request_uri
            redirect_to reader_login_url
          }
          format.js {
            render :template => 'readers/login', :layout => false
          }
        end
        false
      end
    end
     
    # it is quite possible to be logged in both as user and reader
    # they may differ or overlap in their priveleges
    # or it may be useful for an admin to masquerade as a reader to review pages

    def login_from_cookie_with_readers
      if !cookies[:reader_session_token].blank? && reader = Reader.find_by_session_token(cookies[:reader_session_token]) # don't find by empty value
        reader.remember_me
        self.current_reader = reader
        set_session_cookie
      end
      login_from_cookie_without_readers
    end
    
    def set_session_cookie_with_readers
      set_reader_cookie if current_reader
      set_session_cookie_without_readers if current_user
    end
    
    def set_reader_cookie
      cookies[:reader_session_token] = { :value => current_reader.session_token , :expires => Radiant::Config['session_timeout'].to_i.from_now.utc }
    end
    
  private

    def set_current_reader
      Reader.current_reader = current_reader
    end

  module ClassMethods
    def no_reader_required
      skip_before_filter :authenticate_reader
    end

    def reader_required?
      filter_chain.any? {|f| f.method == :authenticate_reader }
    end

    def reader_required
      before_filter :authenticate_reader
    end
    
  end
end






