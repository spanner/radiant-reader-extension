class ReadersController < ApplicationController
  radiant_layout 'master'
  no_login_required
  skip_before_filter :verify_authenticity_token

  only_allow_access_to :index, :remove,
    :when => :admin,
    :denied_url => {:controller => 'page', :action => :me},
    :denied_message => 'You must have administrative privileges to list or affect other readers.'

  def index
    @readers = Reader.paginate(:page => params[:page], :order => 'readers.created_at desc')
  end

  def show
    @reader = Reader.find(params[:id])
    respond_to do |format|
      format.html
      format.rss  { render :layout => false }
    end
  end

  def new
    @reader = Reader.new
  end
  
  def edit
    @reader = Reader.find(params[:id])
    # fail unless current_reader or admin
  end
  
  def create
    @reader = Reader.new(params[:reader])
    @reader.login = @reader.email if @reader.login.blank?
    @reader.password = params[:password]
    @reader.password_confirmation = params[:password_confirmation]
    @reader.current_password = params[:password]
    
    if (@reader.valid?)
      @reader.save
      self.current_reader = @reader
      redirect_to :action => 'activate'
    else
      render :action => 'new'
    end
  end

  def activate
    render and return if params[:activation_code].nil?
    render and return if params[:id].nil? && params[:email].nil?
    @reader = params[:id] ? Reader.find_by_id_and_activation_code(params[:id], params[:activation_code]) : Reader.find_by_email_and_activation_code(params[:email], params[:activation_code])
    
    if @reader
      @reader.activate
      self.current_reader = @reader
      flash[:notice] = "Thank you! Your account has been activated."
      redirect_to url_for(@reader)
    else
      flash[:error] = "Unable to activate your account. Please check activation code."
      render
    end
  end

  # password returns (and then processes) a reset my password form

  def password
    render and return unless request.post?
    flash[:error] = "Please enter an email address." if params[:email].nil? 
    @reader = Reader.find_by_email(params[:email])
    if @reader.nil?
      @error = flash[:error] = "Sorry. That address is not known here."
      render and return
    end
    unless @reader.activated?
      @reader.send_welcome_message
      @error = "Sorry: You can't change the password for an account that hasn't been activated. We have resent the activation message instead. Clicking the activation link will log you in and allow you to change your password." 
      flash[:error] = @error
      render and return
    end
    @reader.repassword
    render
  end
  
  # repassword is hit when they click on the confirmation link or enter the code
  
  def repassword
    redirect_to :action => 'password' if params[:activation_code].nil? || params[:id].nil?
    @reader = Reader.find_by_id_and_activation_code(params[:id], params[:activation_code])
    if @reader 
      @reader.confirm_password(params[:activation_code])
      self.current_reader = @reader
      flash[:notice] = "Hello #{@reader.name}. Your password has been reset and you are now logged in." 
      redirect_to url_for(@reader)
    else
      flash[:error] = "Unable to reset your password. Please check activation code. If you received more than one message, ignore all but the latest one." 
      redirect_to :action => 'password'
    end
  end

  def update
    @reader = current_reader
    @reader.attributes = params[:reader]
    if @reader.authenticate(@reader.login, params[:current_password])
      @reader.password = params[:password]
      @reader.password_confirmation = params[:password_confirmation]
      if @reader.save
        flash[:notice] = "Your account has been updated"
        redirect_to url_for(@reader)
      else
        render :action => 'edit'
      end
    else
      flash[:error] = 'Wrong password!'
      @reader.valid?    # so that we can flag any other errors on the form
      @reader.errors.add(:current_password, "not correct")
      render :action => 'edit'
    end
  end
    
  def login
    if request.post?
      login = params[:reader][:login]
      password = params[:reader][:password]
      flash[:error] = "sorry: login not correct" unless current_reader = Reader.authenticate(login, password)
    end
    if current_reader
      if params[:remember_me]
        current_reader.remember_me
        set_session_cookie
      end
      flash[:notice] = "Hello #{current_reader.name}. You are now logged in"
      redirect_to params[:backto] || :back
    end
  end
  
  def logout
    cookies[:session_token] = { :expires => 1.day.ago }
    current_reader.forget_me
    flash[:notice] = "Goodbye #{current_reader.name}. You are now logged out"
    current_reader = nil
    redirect_to :back
  end
     
end
