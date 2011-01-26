class ReadersController < ReaderActionController
  helper :reader
  
  cattr_accessor :edit_partials, :show_partials, :index_partials
  
  before_filter :check_registration_allowed, :only => [:new, :create]
  before_filter :initialize_partials
  before_filter :i_am_me, :only => [:show, :edit]
  before_filter :require_reader, :except => [:index, :new, :create, :activate]
  before_filter :restrict_to_self, :only => [:edit, :update, :resend_activation]
  before_filter :no_removing, :only => [:remove, :destroy]
  before_filter :require_password, :only => [:update]

  def index
    @readers = Reader.all.paginate(pagination_parameters.merge(:per_page => 60))
  end

  def show
    @reader = Reader.find(params[:id])
    respond_to do |format|
      format.html { 
        if @reader.inactive? && @reader == current_reader
          redirect_to reader_activation_url
        else
          render
        end
      }
      format.js { 
        @inline = true
        render :partial => 'readers/controls'
      }
    end
  end

  def new
    if current_reader
      flash[:error] = t('already_logged_in')
      redirect_to url_for(current_reader) and return
    end
    @reader = Reader.new
    session[:return_to] = request.referer
    session[:email_field] = @reader.generate_email_field_name
  end
  
  def edit
  end
  
  def create
    @reader = Reader.new(params[:reader])
    @reader.clear_password = params[:reader][:password]

    unless @reader.email.blank?
      flash[:error] = t('please_avoid_spam_trap')
      @reader.email = ''
      @reader.errors.add(:trap, t("must_be_empty"))
      render :action => 'new' and return
    end

    unless @email_field = session[:email_field]
      flash[:error] = 'please_use_form'
      redirect_to new_reader_url and return
    end

    @reader.email = params[@email_field.intern]
    if (@reader.valid?)
      @reader.save!
      @reader.send_activation_message
      self.current_reader = @reader
      redirect_to reader_activation_url
    else
      render :action => 'new'
    end
  end

  def update
    @reader.attributes = params[:reader]
    @reader.clear_password = params[:reader][:password] if params[:reader][:password]
    if @reader.save
      flash[:notice] = t('account_updated')
      redirect_to url_for(@reader)
    else
      render :action => 'edit'
    end
  end
  
protected

  def i_am_me
    params[:id] = current_reader.id if current_reader && params[:id] == 'me'
  end

  def restrict_to_self
    flash[:error] = t("cannot_edit_others") if params[:id] && params[:id] != current_reader.id
    @reader = current_reader
  end
  
  def require_password
    return true if @reader.valid_password?(params[:reader][:current_password])

    # might as well get any other validation messages while we're at it
    @reader.attributes = params[:reader]
    @reader.valid?
    
    flash[:error] = t('password_incorrect')
    @reader.errors.add(:current_password, "not_correct")
    render :action => 'edit' and return false
  end
  
  def no_removing
    flash[:error] = t('cannot_delete_readers')
    redirect_to admin_readers_url
  end
  
  def check_registration_allowed
    unless Radiant::Config['reader.allow_registration?']
      flash[:error] = t("registration_disallowed")
      redirect_to reader_login_url
      false
    end
  end
  
  def self.add_edit_partial(path)
    @@edit_partials ||= []
    edit_partials.push(path)
  end

  def self.add_show_partial(path)
    @@show_partials ||= []
    show_partials.push(path)
  end

  def self.add_index_partial(path)
    @@index_partials ||= []
    index_partials.push(path)
  end

private
  def initialize_partials
    @show_partials = show_partials
    @edit_partials = edit_partials
    @index_partials = index_partials
  end

end
