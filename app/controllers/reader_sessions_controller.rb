class ReaderSessionsController < ApplicationController
  
  before_filter :require_no_reader, :only => [:new, :create]
  before_filter :require_reader, :only => :destroy
  radiant_layout { |controller| controller.layout_for :reader }
  
  def new
    @reader_session = ReaderSession.new
  end
  
  def create
    @reader_session = ReaderSession.new(params[:reader_session])
    if @reader_session.save
      flash[:notice] = "Login successful!"
      if @reader_session.reader.activated? && @reader_session.reader.clear_password        
        @reader_session.reader.clear_password = ""                          # we forget the cleartext version on the first successful login after activation
        @reader_session.reader.save(false)
      end
      redirect_back_or_to url_for(@reader_session.reader)
    else
      render :action => :new
    end
  end
  
  def destroy
    current_reader_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_to reader_login_url
  end

end
