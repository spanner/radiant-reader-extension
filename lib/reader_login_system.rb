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

  # this should all feel familiar

  protected
    
    def current_reader
      @current_reader ||= current_user ? Reader.find_or_create_for_user(current_user) : Reader.find(session['reader_id']) rescue nil
    end
    
    def current_reader=(reader=nil)
      if reader && reader.is_a?(Reader)
        session['reader_id'] = reader.id
        reader.timestamp
        @current_reader = reader
      else
        session['reader_id'] = nil
        @current_reader = nil
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

    def login_from_cookie_with_readers
      if !cookies[:reader_session_token].blank? && reader = Reader.find_by_session_token(cookies[:reader_session_token])
        reader.remember_me
        self.current_reader = reader
        self.current_user = reader.user if reader.is_user?
        set_session_cookie
      end
      login_from_cookie_without_readers unless current_user
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






