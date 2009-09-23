class Admin::MessagesController < Admin::ResourceController

  # ResourceController doesn't normally show
  skip_before_filter :load_model
  before_filter :load_model, :except => :index
  
  # mock email view called into an iframe in the :show view
  def preview
    render :layout => false
  end
  
  def deliver
    @message.deliver
    flash[:notice] = "message delivered"
    redirect_to admin_message_url(@message)
  end

protected

  # we normally want to redirect to :show for preview and delivery options
  def continue_url(options)
    params[:continue] ? edit_admin_message_path(model.id) : admin_message_path(model.id)
  end

end
