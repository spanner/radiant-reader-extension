class ReaderActivationsController < ReaderActionController
  helper :reader

  no_login_required
  skip_before_filter :require_reader
  before_filter :authenticate_reader, :only => [:update]
  before_filter :check_reader_inactive
  
  radiant_layout { |controller| Radiant::Config['reader.layout'] }

  # this is just fake REST: we're actually working on the reader, not an activation object.
  # .show sends out an activation message if we can identify the current reader
  # .update activates the reader, if the token is correct

  def show
    expires_now
    render
  end
  
  def new
    if current_reader
      @reader = current_reader
      @reader.send_activation_message
      flash[:notice] = t("activation_message_sent")
    end
    expires_now
    render :action => 'show'
  end
  
  def update
    if @reader
      @reader.activate!
      self.current_reader = @reader
    else
      @error = t("please_check_message")
    end
    expires_now
    render :action => 'show'
  end

protected

  def authenticate_reader
    # not using authlogic's find_using_perishable_token because I don't want the token to expire
    @reader = Reader.find_by_id_and_perishable_token(params[:id], params[:activation_code])
  end

  def check_reader_inactive
    if @reader && @reader.activated?
      flash[:notice] = t('hello').titlecase + " #{@reader.name}! " + t('already_active')
      redirect_back_or_to default_activated_url
      false
    end
  end

  def default_activated_url
    reader_url(@reader)
  end

end
