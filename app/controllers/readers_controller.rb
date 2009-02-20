class ReadersController < ApplicationController
  no_login_required
  before_filter :no_removing, :only => [:remove, :destroy]

  radiant_layout { |controller| controller.find_readers_layout }

  # I have no idea where this default is being overridden
  skip_before_filter :verify_authenticity_token if ENV["RAILS_ENV"] == "test"

  def index
    @readers = Reader.paginate(:page => params[:page], :order => 'readers.created_at desc')
  end
  
  def show
    redirect_to reader_login_url and return unless current_reader
    @reader = Reader.find(params[:id])
  end

  alias_method :me, :show

  def new
    redirect_to url_for(current_reader) and return if current_reader
    @reader = Reader.new
  end
  
  def edit
    @reader = current_reader
    flash[:error] = "you cannot edit another person's account" if params[:id] && @reader.id != params[:id]
  end
  
  def create
    @reader = Reader.new(params[:reader])
    @reader.password = params[:password]
    @reader.password_confirmation = params[:password_confirmation]
    @reader.current_password = params[:password]
    if (@reader.valid?)
      @reader.save!
      self.current_reader = @reader
      redirect_to :action => 'activate'
    else
      render :action => 'new'
    end
  end

  # fix this to give a specific error message

  def activate
    if params[:activation_code].nil?
      render and return 
    end

    if params[:id].nil? && params[:email].nil?
      flash[:error] = "Email address or accound id is required. Please look again at your activation message."
      render and return
    end

    @reader = params[:id] ? Reader.find(params[:id]) : Reader.find_by_email(params[:email])
    if @reader && @reader.activate!(params[:activation_code])
      self.current_reader = @reader
      flash[:notice] = "Thank you! Your account has been activated."
      redirect_to url_for(@reader)
    else
      flash[:error] = "Unable to activate your account. Please check activation code."
    end
  end

  # password returns (and then processes) a reset my password form

  def password
    render and return unless request.post?
    flash[:error] = "Please enter an email address." if params[:email].nil? 
    @reader = params[:email] && Reader.find_by_email(params[:email])
    if @reader.nil? || !@reader
      @error = flash[:error] = "Sorry. That address is not known here."
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
    if @reader.authenticated?(params[:current_password])
      @reader.attributes = params[:reader]
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
    set_session_cookie
    flash[:notice] = "Goodbye #{current_reader.name}. You are now logged out"
    current_reader = nil
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
