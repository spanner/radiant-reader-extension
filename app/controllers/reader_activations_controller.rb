class ReaderActivationsController < ReaderActionController

  no_login_required
  skip_before_filter :require_reader
  before_filter :authenticate_reader, :only => [:update]
  before_filter :check_reader_inactive
  
  radiant_layout { |controller| controller.layout_for :reader }

  # this is just fake REST: we're actually working on the reader, not an activation object, but in a usefully restricted way:
  # .show sends out an activation message if we can identify the current reader
  # .update activates the reader, if the token is correct

  def show
    render
  end
  
  def new
    if current_reader
      @reader = current_reader
      @reader.send_activation_message
      flash[:notice] = "Account activation instructions have been emailed to you."
    end
    render :action => 'show'
  end
  
  def update
    if @reader
      @reader.activate!
      self.current_reader = @reader
      flash[:notice] = "Thank you! Your account has been activated."
      redirect_back_or_to default_activated_url
      
    else
      @error = "Sorry: something was wrong in that link. Please check your email message."
      flash[:error] = "Activation failed."
      render :action => 'show'
    end
  end

protected

  def authenticate_reader
    # not using authlogic's find_using_perishable_token because I don't want the token to expire
    @reader = Reader.find_by_id_and_perishable_token(params[:id], params[:activation_code])
  end

  def check_reader_inactive
    if @reader && @reader.activated?
      flash[:notice] = "Hello #{@reader.name}! Your account is already active."
      redirect_back_or_to default_activated_url
      false
    end
  end

  def default_activated_url
    reader_url(@reader)
  end

end
