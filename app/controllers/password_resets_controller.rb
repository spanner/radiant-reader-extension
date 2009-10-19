class PasswordResetsController < ApplicationController

  # rest gone mad! but it works, and keeps the processes well-defined.

  no_login_required 
  before_filter :get_reader, :only => [:edit, :update]
  radiant_layout { |controller| controller.layout_for :reader }
  
  def new
    render
  end
  
  def create
    @reader = Reader.find_by_email(params[:email])
    if @reader
      if @reader.activated?
        @reader.send_password_reset_message
        flash[:notice] = "Password reset instructions have been emailed to you."
        render
      else
        @reader.send_activation_message
        flash[:notice] = "Account activation instructions have been emailed to you."
        redirect_to new_reader_activation_url
      end
    else  
      @error = flash[:error] = "Sorry. That email address is not known here."  
      render :action => :new  
    end  
  end

  def edit  
    if @reader
      flash[:notice] = "Thank you. Please enter and confirm a new password."
    else
      flash[:error] = "Sorry: can't find you."
    end
    render
  end  

  def update
    if @reader 
      @reader.password = params[:reader][:password]
      @reader.password_confirmation = params[:reader][:password_confirmation]
      if @reader.save 
        self.current_reader = @reader
        flash[:notice] = "Thank you. Your password has been updated and you are now logged in."
        redirect_to url_for(@reader)
      else
        flash[:error] = "Passwords don't match! Please try again."
        render :action => :edit 
      end  
    else
      flash[:error] = "Sorry: can't find you."
      render :action => :edit     # without @reader, this will take us back to the enter-your-code form
    end
  end  

private  

  def get_reader
    @reader = Reader.find_by_id_and_perishable_token(params[:id], params[:confirmation_code])
  end  

end
