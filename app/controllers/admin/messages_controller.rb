class Admin::MessagesController < Admin::ResourceController
  before_filter :set_function, :only => :new
  
  def index
    redirect_to admin_reader_settings_url
  end
  
protected

  def continue_url(options)
    admin_reader_settings_url
  end

  def set_function
    if params[:function]
      @message.function_id = params[:function]
    end
  end

end
