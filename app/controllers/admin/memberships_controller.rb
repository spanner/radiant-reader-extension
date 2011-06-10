class Admin::MembershipsController < ApplicationController
    
  before_filter :find_group
  
  def index
    redirect_to admin_group_url(@group)
  end
  
  def create
    @reader = Reader.find(params[:reader_id])
    raise ActiveRecord::RecordNotFound unless @reader
    @membership = Membership.find_or_create_by_reader_id_and_group_id(@reader.id, @group.id)
    respond_to do |format|
      format.html { 
        flash[:notice] = "#{@reader.name} added to group #{@group.name}"
        redirect_to admin_group_url(@group) 
      }
      format.js { render :partial => 'reader' }
    end
  end
  
  def destroy
    @membership = @group.memberships.find(params[:id])
    @reader = @membership.reader
    @membership.delete if @membership
    respond_to do |format|
      format.html { 
        flash[:notice] = "#{@reader.name} removed from group #{@group.name}" if @membership
        redirect_to admin_group_url(@group) 
      }
      format.js { render :partial => 'reader' }
    end
  end
  
protected

  def find_group
    @group = Group.find(params[:group_id])
    raise ActiveRecord::RecordNotFound unless @group
  end
    
end
