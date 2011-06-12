class Admin::MessagesController < Admin::ResourceController
  helper :reader
  skip_before_filter :load_model
  before_filter :load_model, :except => :index    # we want the filter to run before :show too
  before_filter :set_function, :only => :new
  before_filter :get_group, :only => :new

  # here :show is the preview/send page
  def show
    
  end
  
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
    else
      redirect_to admin_message_url(@message)
      return
    end
    failures = @message.deliver(@readers) || []
    if failures.any?
      if failures.length == @readers.length
        flash[:error] = t("reader_extension.all_deliveries_failed")
      else
        addresses = failures.map(&:email).to_sentence
        flash[:notice] = t("reader_extension.some_deliveries_failed")
      end
    else
      flash[:notice] = t("reader_extension.message_delivered")
    end
    redirect_to admin_message_url(@message)
  end

protected

  def continue_url(options)
    if action_name == "destroy"
      redirect_to :back
    else
      options[:redirect_to] || (params[:continue] ? {:action => 'edit', :id => model.id} : admin_message_url(model))
    end
  end

  def set_function
    if params[:function]
      model.function_id = params[:function]
    end
  end
  
  def get_group
    model.group = Group.find(params[:group_id]) if params[:group_id]
  end

end
