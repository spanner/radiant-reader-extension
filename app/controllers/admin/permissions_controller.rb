class Admin::PermissionsController < ApplicationController
    
  before_filter :find_page_and_group
  
  def index
    redirect_to admin_group_url(@group)
  end
  
  def create
    @page = Page.find(params[:page_id])
    scope = @group.permissions.for(@page)
    @permission = scope.first || scope.create!
    respond_to do |format|
      format.html { 
        flash[:notice] = "#{@page.title} bound to group #{@group.name}"
        redirect_to admin_group_url(@group) 
      }
      format.js { render :partial => 'page' }
    end
  end
  
  def destroy
    @permission ||= @group.permissions.find(params[:id])
    @page = @permission.permitted
    @permission.delete if @permission
    respond_to do |format|
      format.html { 
        flash[:notice] = "#{@page.title} released from group #{@group.name}"
        redirect_to admin_group_url(@group)
      }
      format.js { render :partial => 'page' }
    end
  end
  
  def toggle
    if @permission = @group.permission_for(@page)
      destroy
    else
      create
    end
  end
  
protected

  def find_page_and_group
    @group = Group.find(params[:group_id])
    @page = Page.find(params[:page_id]) if params[:page_id]
  end

end
