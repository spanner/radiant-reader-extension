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
      redirect_back_or_to @reader_session.reader.homepage
    else
      render :action => :new
    end
  end
  
  def destroy
    current_reader_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_to new_reader_session_url
  end

end
