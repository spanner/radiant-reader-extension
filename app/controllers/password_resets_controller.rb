class PasswordResetsController < ReaderActionController
  helper :reader

  # rest gone mad! but it works, and keeps the processes well-defined.

  no_login_required
  skip_before_filter :require_reader
  before_filter :get_reader, :only => [:edit, :update]
  radiant_layout { |controller| Radiant::Config['reader.layout'] }
  
  def new
    render
  end
  
  def create
    @reader = Reader.find_by_email(params[:email])
    if @reader
      if @reader.activated?
        @reader.send_password_reset_message
        render
      else
        @reader.send_activation_message
        redirect_to new_reader_activation_url
      end
    else  
      @error = flash[:error] = t("email_unknown")
      render :action => :new  
    end  
  end

  def edit  
    unless @reader
      flash[:error] = t('reset_not_found')
    end
    render
  end  

  def update
    if @reader 
      @reader.password = params[:reader][:password]
      @reader.password_confirmation = params[:reader][:password_confirmation]
      if @reader.save 
        self.current_reader = @reader
        flash[:notice] = t('password_updated_notice')
        redirect_to url_for(@reader)
      else
        flash[:error] = t('password_mismatch')
        render :action => :edit 
      end  
    else
      flash[:error] = t('reset_not_found')
      render :action => :edit     # without @reader, this will take us back to the enter-your-code form
    end
  end  

private  

  def get_reader
    @reader = Reader.find_by_id_and_perishable_token(params[:id], params[:confirmation_code])
  end  

end
