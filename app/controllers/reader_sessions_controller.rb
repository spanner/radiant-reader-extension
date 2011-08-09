class ReaderSessionsController < ReaderActionController
  helper :reader

  before_filter :require_reader, :only => :destroy
  radiant_layout { |controller| Radiant::Config['reader.layout'] }
  
  def show
    @reader = current_reader
    respond_to do |format|
      format.html { 
        if !@reader
          redirect_to reader_login_url
        elsif @reader.inactive?
          redirect_to reader_activation_url
        else
          redirect_to reader_profile_url
        end
      }
      format.js {
        render :partial => 'accounts/controls', :layout => false
      }
    end
  end
  
  def new
    if current_reader
      if current_reader.activated?
        cookies[:error] = t('reader_extension.already_logged_in')
        redirect_to default_welcome_url(current_reader)
      else
        cookies[:error] = t('reader_extension.account_requires_activation')
        redirect_to reader_activation_url
      end
    else
      @reader_session = ReaderSession.new
      expires_now
    end
  end
  
  def create
    @reader_session = ReaderSession.new(params[:reader_session])
    @reader_session.save do |success|
      if success
        if @reader_session.reader.activated? && @reader_session.reader.clear_password        
          @reader_session.reader.clear_password = ""                          # we forget the cleartext version on the first successful login
          @reader_session.reader.save(false)
        end
        respond_to do |format|
          format.html {
            flash[:notice] = t('reader_extension.hello').titlecase + " #{@reader_session.reader.name}. " + t('reader_extension.welcome_back')
            redirect_back_or_to default_welcome_url(@reader_session.reader)
          }
          format.js { 
            redirect_back_with_format(:js)
          }
        end
      else
        respond_to do |format|
          format.html { render :action => :new }
          format.js { render :action => :new, :layout => false }
        end
      end
    end
  end
  
  def destroy
    current_reader_session.destroy
    if current_user
      cookies[:session_token] = { :expires => 1.day.ago }
      current_user.forget_me
      session['user_id'] = nil
      current_user = nil
    end
    redirect_to reader_login_url
  end

  def default_welcome_url(reader=nil)
    reader.home_url || dashboard_url
  end

end
