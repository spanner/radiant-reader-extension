class ReadersController < ReaderActionController
  helper :reader
  
  cattr_accessor :dashboard_partials, :dashboard_marginal_partials, :dashboard_links
  @@dashboard_partials = []
  @@dashboard_marginal_partials = []
  @@dashboard_links = []

  before_filter :check_registration_allowed, :only => [:new, :create]
  before_filter :i_am_me, :only => [:show, :edit]
  before_filter :require_reader, :except => [:new, :create, :activate]
  before_filter :default_to_self, :only => [:show]
  before_filter :restrict_to_self, :only => [:edit, :update, :resend_activation]
  before_filter :no_removing, :only => [:remove, :destroy]
  before_filter :ensure_groups_subscribable, :only => [:update, :create]

  def index
    @readers = Reader.visible_to?(current_reader).paginate(pagination_parameters.merge(:per_page => 60))
    # respond to vcard request
    # respond to csv request
  end

  def show
    @reader = Reader.find(params[:id])
  end
  
  def dashboard
    @reader = current_reader
    @dashboard_links = self.class.dashboard_links
    @dashboard_partials = ['dashboard/links', 'dashboard/groups', 'dashboard/profile'] + self.class.dashboard_partials
    @dashboard_marginal_partials = ['dashboard/messages', 'dashboard/directory'] + self.class.dashboard_marginal_partials
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
      redirect_to url_for(@reader)
    else
      render :action => 'edit'
    end
  end
  
  def self.add_dashboard_link(link)
    dashboard_links.push(link)
  end
  
  def self.add_dashboard_partial(partial)
    dashboard_partials.push(partial) unless dashboard_partials.include?(partial)
    Rails.logger.warn "add_dashboard_partial(#{partial}): partials now #{dashboard_partials.inspect}"
  end

  def self.add_marginal_dashboard_partial(partial)
    dashboard_marginal_partials.push(partial) unless dashboard_marginal_partials.include?(partial)
    Rails.logger.warn "add_marginal_dashboard_partial(#{partial}): partials now #{dashboard_marginal_partials.inspect}"
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
