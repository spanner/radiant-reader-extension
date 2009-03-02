class ReadersController < ApplicationController
  no_login_required
  before_filter :authenticate_reader, :only => [:show, :edit, :update]
  before_filter :no_removing, :only => [:remove, :destroy]
  radiant_layout { |controller| controller.find_readers_layout }

  # I have no idea where this default is being overridden
  skip_before_filter :verify_authenticity_token if ENV["RAILS_ENV"] == "test"

  def index
    @readers = Reader.paginate(:page => params[:page], :order => 'readers.created_at desc')
    flash[:notice] = "Herrroooo!"
  end
  
  def show
    @reader = Reader.find(params[:id])
  end

  alias_method :me, :show

  def new
    redirect_to url_for(current_reader) and return if current_reader
    @reader = Reader.new
    session[:email_field] = @email_field = @reader.generate_email_field_name
  end
  
  def edit
    @reader = current_reader    
    flash[:error] = "you can't edit another person's account" if params[:id] && @reader.id != params[:id].to_i
  end
  
  def create
    @reader = Reader.new(params[:reader])
    @reader.password = params[:password]
    @reader.password_confirmation = params[:password_confirmation]
    @reader.current_password = params[:password]
    @email_field = session[:email_field]

    unless @reader.email.blank?
      flash[:error] = "Please don't fill in the spam trap field."
      @reader.email = ''
      @reader.errors.add(:trap, "must be empty")
      render :action => 'new' and return
    end
    unless @email_field
      flash[:error] = "Please use the registration form."
      render :action => 'new' and return
    end
    
    @reader.email = params[@email_field.intern]
    if (@reader.valid?)
      @reader.save!
      self.current_reader = @reader
      redirect_to :action => 'activate'
    else
      render :action => 'new'
    end
  end

  def activate
    if params[:activation_code].nil?
      # probably the initial request
      render and return 
    end

    if params[:id].nil? && params[:email].nil?
      flash[:error] = "Email address or account id is required. Please look again at your activation message."
      render and return
    end

    @reader = params[:id] ? Reader.find(params[:id]) : Reader.find_by_email(params[:email])
    if @reader
      if @reader.activated?
        flash[:notice] = "Hello #{@reader.name}! Your account is already active. Please move along."
        redirect_to url_for(@reader)
      elsif @reader.activate!(params[:activation_code])
        self.current_reader = @reader
        flash[:notice] = "Thank you! Your account has been activated."
        redirect_to url_for(@reader)
      else
        @reader.errors.add(:activation_code, "please check that this is correct")
        flash[:error] = "Unable to activate your account. Please check your activation code."
      end
    else
      flash[:error] = "Unable to activate your account. Please check the activation message."
    end
  end

  # password returns (on get) or processes (on post) a reset my password form

  def password
    render and return unless request.post?
    if params[:email].nil? 
      flash[:error] = "Please enter an email address." 
    else
      @reader = Reader.find_by_email(params[:email])
    end
    unless @reader
      flash[:error] = "Sorry. That address is not known here."
      render and return
    end
    unless @reader.activated?
      @reader.send_activation_message
      @error = "Sorry: You can't change the password for an account that hasn't been activated. We have resent the activation message instead. Clicking the activation link will log you in and allow you to change your password." 
      flash[:error] = @error
      render and return
    end
    @reader.repassword
    render
  end
  
  # repassword is hit when they click on the confirmation link or enter the code in the reset my password message
  
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
    if @reader.authenticated?(params[:current_password])
      @reader.password = params[:password]
      @reader.password_confirmation = params[:password_confirmation]
      if @reader.save
        flash[:notice] = "Your account has been updated"
        redirect_to url_for(@reader)
      else
        render :action => 'edit'
      end
    else
      flash[:error] = "That's not the right password!"
      @reader.valid?    # so that we can flag any other errors on the form
      @reader.errors.add(:current_password, "not correct")
      render :action => 'edit'
    end
  end
        
  def login
    if request.post?
      login = params[:reader][:login]
      password = params[:reader][:password]
      flash[:error] = "sorry: login not correct" unless @reader = Reader.authenticate(login, password)
    end
    if @reader
      Reader.current_reader = self.current_reader = @reader
      if params[:remember_me]
        @reader.remember_me
        set_reader_cookie
      end
      flash[:notice] = "Hello #{@reader.name}. You are logged in"
      redirect_to session[:return_to] || :back
    end
  end
  
  def logout
    cookies[:reader_session_token] = { :expires => 1.day.ago }
    flash[:notice] = "Goodbye #{current_reader.name}. You are now logged out"
    self.current_reader.forget_me
    Reader.current_reader = self.current_reader = nil
    redirect_to :back
  end

  def no_removing
    announce_cannot_delete_readers
    redirect_to admin_readers_url
  end
      
  private
  
    def announce_cannot_delete_readers
      flash[:error] = 'You cannot delete readers here. Please log in to the admin interface.'
    end  
     
end
