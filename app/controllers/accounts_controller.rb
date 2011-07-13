class AccountsController < ReaderActionController
  helper :reader
  
  before_filter :check_registration_allowed, :only => [:new, :create, :activate]
  before_filter :i_am_me, :only => [:show, :edit, :edit_profile]
  before_filter :require_reader, :except => [:new, :create, :activate]
  before_filter :default_to_self, :only => [:show]
  before_filter :restrict_to_self, :only => [:edit, :edit_profile, :update, :resend_activation]
  before_filter :no_removing, :only => [:remove, :destroy]
  before_filter :ensure_groups_subscribable, :only => [:update, :create]

  def index
    @readers = Reader.visible_to(current_reader)
    respond_to do |format|
      format.html {}
      format.csv {
        send_data generate_csv(@readers), :type => 'text/csv; charset=utf-8; header=present', :filename => "everyone.csv"
      }
      format.vcard {
        send_data @readers.map(&:vcard).join("\n"), :filename => "everyone.vcf"
      }
    end
  end

  def show
    @reader = Reader.find(params[:id])
    respond_to do |format|
      format.html
      format.vcard {
        send_data @reader.vcard.to_s, :filename => "#{@reader.filename}.vcf"	
      }
    end
  end
  
  def dashboard
    # @reader = current_reader
    expires_now
  end

  def new
    if current_reader
      flash[:error] = t('reader_extension.already_logged_in')
      redirect_to url_for(current_reader) and return
    end
    @reader = Reader.new
    session[:return_to] = request.referer
    session[:email_field] = @reader.generate_email_field_name
  end
  
  def edit
    expires_now
  end

  def edit_profile
    expires_now
  end

  def create
    @reader = Reader.new(params[:reader])
    @reader.clear_password = params[:reader][:password]

    unless @reader.email.blank?
      flash[:error] = t('reader_extension.please_avoid_spam_trap')
      @reader.email = ''
      @reader.errors.add(:trap, t("reader_extension.must_be_empty"))
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
      @reader.email_field = session[:email_field]
      render :action => 'new'
    end
  end

  def update
    @reader.attributes = params[:reader]
    @reader.clear_password = params[:reader][:password] if params[:reader][:password]
    if @reader.save
      flash[:notice] = t('reader_extension.account_updated')
      redirect_to dashboard_url
    else
      render :action => 'edit'
    end
  end
  
protected

  def i_am_me
    params[:id] = current_reader.id if current_reader && params[:id] == 'me'
  end

  def default_to_self
    params[:id] ||= current_reader.id
  end
  
  def restrict_to_self
    flash[:error] = t("reader_extension.cannot_edit_others") if params[:id] && params[:id] != current_reader.id
    @reader = current_reader
  end
  
  def require_password
    return true if @reader.valid_password?(params[:reader][:current_password])

    # might as well get any other validation messages while we're at it
    @reader.attributes = params[:reader]
    @reader.valid?
    
    flash[:error] = t('reader_extension.password_incorrect')
    @reader.errors.add(:current_password, "not_correct")
    render :action => 'edit' and return false
  end
  
  def no_removing
    flash[:error] = t('reader_extension.cannot_delete_readers')
    redirect_to admin_readers_url
  end
  
  def check_registration_allowed
    unless Radiant::Config['reader.allow_registration?']
      flash[:error] = t("reader_extension.registration_disallowed")
      redirect_to reader_login_url
      false
    end
  end
  
private

  def ensure_groups_subscribable
    if params[:reader] && params[:reader][:group_ids]
      params[:reader][:group_ids].each do |g|
        raise ActiveRecord::RecordNotFound unless Group.find(g).public?
      end
    end
    true
  rescue ActiveRecord::RecordNotFound
    false
  end

end
