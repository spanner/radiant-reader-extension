class MessagesController < ReaderActionController

  before_filter :require_reader
  before_filter :get_messages, :only => [:index]
  before_filter :get_message, :only => [:show, :preview]

  def index
    render
  end
  
  def show
    render
  end

  # mock email view called into an iframe in the :show view
  # the preview template calls @message.preview, which returns the message body
  # wrapped in the layout defined by the Notifier: 
  # layout here is false so that we don't add another one
  
  def preview
    render :layout => false
  end
  
protected

  def get_messages
    @messages = current_reader.messages
  end
  
  def get_message
    @message = current_reader.messages.find(params[:id])
  end

end
