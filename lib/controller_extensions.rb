module ControllerExtensions    # for inclusion into ApplicationController

  def self.included(base)
    
    base.class_eval do
      rescue_from ReaderError::AccessDenied, :with => :access_denied
      rescue_from ReaderError::LoginRequired, :with => :login_required
      rescue_from ReaderError::ActivationRequired, :with => :activation_required

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
        current_reader_session = ReaderSession.create!(Reader.for_user(current_user))
      end
    end

    def set_reader
      Reader.current = current_reader
    end

    def store_location(location = request.request_uri)
      session[:return_to] = location
    end

    def redirect_back
      if session[:return_to]
        redirect_to session[:return_to]
        session[:return_to] = nil
        true
      else
        false
      end
    end

    def redirect_back_or_to(default)
      redirect_back or redirect_to(default)
    end

    def redirect_back_with_format(format = 'html')
      Rails.logger.warn "<<< redirect_back_with_format. session[:return_to] is #{session[:return_to].inspect}"
      address = session[:return_to]
      previous_format = File.extname(address)
      raise StandardError, "Can't add format to an already formatted url: #{address}" unless previous_format.blank? || previous_format == format
      redirect_to address + ".#{format}"    # nasty! but necessary for inline login.
    end

    # reader-permission exception handling

    def login_required(e)
      @message = e.message
      respond_to do |format|
        format.html {
          flash[:explanation] = t('reader_extension.reader_required')
          flash[:notice] = e.message
          redirect_to reader_login_url 
        }
        format.js { 
          @inline = true
          render :partial => 'reader_sessions/login_form'
        }
      end
    end

    def activation_required(e)
      @message = e.message
      respond_to do |format|
        format.html { 
          flash[:explanation] = t('reader_extension.activation_required')
          redirect_to reader_activation_url 
        }
        format.js { 
          @inline = true
          render :partial => 'reader_activations/activation_required' 
        }
      end
    end

    def access_denied(e)
      @message = e.message
      respond_to do |format|
        format.html { 
          flash[:explanation] = t('reader_extension.access_denied')
          flash[:notice] = e.message
          render :template => 'shared/not_allowed' 
        }
        format.js { 
          render :text => @message, :status => 403
        }
      end
    end

  end
end







