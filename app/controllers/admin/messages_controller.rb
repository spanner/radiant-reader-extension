class Admin::MessagesController < Admin::ResourceController
  
  def index
    redirect_to admin_reader_settings_url
  end
  
protected

  def continue_url(options)
    admin_reader_settings_url
  end

end
