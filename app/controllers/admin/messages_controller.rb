class Admin::MessagesController < Admin::ResourceController

  # ResourceController doesn't normally show
  skip_before_filter :load_model
  before_filter :load_model, :except => :index
  
  # mock email view called into an iframe in the :show view
  # the view calls @message.preview, which returns the message body
  def preview
    render :layout => false
  end
  
  def deliver
    case params['delivery']
    when "all"
      @readers = @message.possible_readers
    when "inactive"
      @readers = @message.inactive_readers
    when "unsent"
      @readers = @message.undelivered_readers
    when "selection"
      @readers = @message.possible_readers.find(params[:reader_ids])
    else
      redirect_to admin_message_url(@message)
      return
    end
    failures = @message.deliver(@readers) || []
    if failures.any?
      if failures.length == @readers.length
        flash[:error] = "All deliveries failed"
      else
        addresses = failures.map(&:email).to_sentence
        flash[:notice] = "some deliveries failed: #{addresses}"
      end
    else
      flash[:notice] = "message delivered to #{@readers.length} #{@template.pluralize(@readers.length, 'reader')}"
    end
    redirect_to admin_message_url(@message)
  end

protected

  # we normally want to redirect to :show for preview and delivery options
  def continue_url(options)
    params[:continue] ? edit_admin_message_path(model.id) : admin_message_path(model.id)
  end

end
