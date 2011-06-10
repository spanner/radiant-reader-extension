class Admin::PermissionsController < ApplicationController
    
  before_filter :find_group
  
  def index
    redirect_to admin_group_url(@group)
  end
  
  def create
    @page = Page.find(params[:page_id])
    raise ActiveRecord::RecordNotFound unless @page
    @permission = Permission.find_or_create_by_page_id_and_group_id(@page.id, @group.id)
    respond_to do |format|
      format.html { 
        flash[:notice] = "#{@page.name} bound to group #{@group.name}"
        redirect_to admin_group_url(@group) 
      }
      format.js { render :partial => 'page' }
    end
  end
  
  def destroy
    @permission = @group.permissions.find(params[:id])
    @page = @permission.page
    @permission.delete if @permission
    respond_to do |format|
      format.html { 
        flash[:notice] = "#{@page.name} released from group #{@group.name}"
        redirect_to admin_group_url(@group)
      }
      format.js { render :partial => 'page' }
    end
  end
  
protected

  def find_group
    @group = Group.find(params[:group_id])
    raise ActiveRecord::RecordNotFound unless @group
  end
  
end
