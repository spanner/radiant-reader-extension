class ReadersController < ReaderActionController

  before_filter :require_reader, :except => [:index, :new, :create, :activate]
  before_filter :i_am_me, :only => [:show]
  before_filter :restrict_to_self, :only => [:edit, :update, :resend_activation]
  before_filter :no_removing, :only => [:remove, :destroy]
  before_filter :require_password, :only => [:update]

  def index
    @readers = Reader.paginate(:page => params[:page], :order => 'readers.created_at desc')
  end

  def show
    @reader = Reader.find(params[:id])
    if @reader.inactive? && @reader == current_reader
      render :action => 'activate'
    end
  end

  def new
    if current_reader
      flash[:error] = "You're already logged in!"
      redirect_to url_for(current_reader) and return
    end
    @reader = Reader.new
    session[:return_to] = request.referer
    session[:email_field] = @email_field = @reader.generate_email_field_name
  end
  
  def edit
    @reader = current_reader
    flash[:error] = "You can't edit another person's preferences" if params[:id] && @reader.id != params[:id].to_i
  end
  
  def create
    @reader = Reader.new(params[:reader])
    @reader.clear_password = params[:reader][:password]

    unless @reader.email.blank?
      flash[:error] = "Please don't fill in the spam trap field."
      @reader.email = ''
      @reader.errors.add(:trap, "must be empty")
      render :action => 'new' and return
    end

    unless @email_field = session[:email_field]
      flash[:error] = "Please use the registration form."
      redirect_to new_reader_url and return
    end

    @reader.email = params[@email_field.intern]
    if (@reader.valid?)
      @reader.save!
      @reader.send_activation_message
      self.current_reader = @reader
      render
    else
      render :action => 'new'
    end
  end

  def update
    @reader.attributes = params[:reader]
    @reader.clear_password = params[:reader][:password] if params[:reader][:password]
    if @reader.save
      flash[:notice] = "Your account has been updated"
      redirect_to url_for(@reader)
    else
      render :action => 'edit'
    end
  end

  # a proper rest fanatic would do this with a reader_activations controller
  # and possibly even an activations class that remembers the cleartext password and time of invitation

  def activate
    if params[:activation_code].nil?
      # probably redirected from registration page
      render and return 
    end

    if params[:id].nil?
      # shouldn't happen unless someone is trying addresses
      flash[:error] = "Sorry: bad link. Please look again at your activation message."
      render and return
    end
    
    @reader = Reader.find_by_id_and_perishable_token(params[:id], params[:activation_code])    #NB not using authlogic's find_using_perishable_token because I don't want the token to time out

    if @reader
      if @reader.activated?
        flash[:notice] = "Hello #{@reader.name}! Your account is already active."
        redirect_to url_for(@reader)
        
      else
        @reader.activate!
        self.current_reader = @reader
        flash[:notice] = "Thank you! Your account has been activated."
        render
      end
      
    else
      @error = "Sorry: the activation code was not correct. Please check the link in your email message. If it's broken over two lines you might need to put it back together."
      flash[:error] = "Sorry: can't find you."
    end
  end
  
  def resend_activation
    if @reader.activated?
      flash[:notice] = "Hello #{@reader.name}! Your account is already active."
    else
      @reader.send_activation_message
      flash[:notice] = "Activation message sent to #{@reader.email}."
    end
    redirect_to url_for(@reader)
  end

  def default_welcome_page(reader = current_reader)
    reader.is_user? ? admin_pages_url : reader.homepage
  end
  
  def permission_denied
    session[:return_to] ||= request.referer
    @title = flash[:error] || "Sorry: permission denied"
    render
  end
  
protected

  def i_am_me
    params[:id] = current_reader.id if params[:id] == 'me'
  end

  def restrict_to_self
    @reader = current_reader
  end
  
  def require_password
    return true if @reader.valid_password?(params[:reader][:current_password])

    # might as well get any other validation messages while we're at it
    @reader.attributes = params[:reader]
    @reader.valid?
    
    flash[:error] = 'Wrong password.'
    @reader.errors.add(:current_password, "was not correct")
    render :action => 'edit' and return false
  end
  
  def no_removing
    flash[:error] = "You can't delete readers here. Please log in to the admin interface."
    redirect_to admin_readers_url
  end
         
end
