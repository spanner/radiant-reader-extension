class Admin::MembershipsController < ApplicationController
    
  before_filter :find_reader_and_group
  
  def index
    redirect_to admin_group_url(@group)
  end
  
  def create
    @membership = Membership.find_or_create_by_reader_id_and_group_id(@reader.id, @group.id)
    respond_to do |format|
      format.html { 
        flash[:notice] = "#{@reader.preferred_name} added to group #{@group.name}"
        redirect_to admin_group_url(@group) 
      }
      format.js { render :partial => 'reader' }
    end
  end
  
  def destroy
    @membership ||= @group.memberships.find(params[:id])
    @reader = @membership.reader
    @membership.delete if @membership
    respond_to do |format|
      format.html { 
        flash[:notice] = "#{@reader.preferred_name} removed from group #{@group.name}" if @membership
        redirect_to admin_group_url(@group) 
      }
      format.js { render :partial => 'reader' }
    end
  end
  
  def toggle
    if @membership = Membership.find_by_reader_id_and_group_id(@reader.id, @group.id)
      destroy
    else
      create
    end
  end
  
  def edit
    @membership = @group.memberships.find(params[:id])
    respond_to do |format|
      format.js { render :partial => 'admin/memberships/role_form' }
    end
  end

  def update
    @membership = @group.memberships.find(params[:id])
    @membership.update_attributes(params[:membership])
    @membership.save!
    respond_to do |format|
      format.js { render :partial => 'admin/memberships/role' }
    end
  end
  
protected

  def find_reader_and_group
    @group = Group.find(params[:group_id])
    @reader = Reader.find(params[:reader_id]) if params[:reader_id]
  end

end
