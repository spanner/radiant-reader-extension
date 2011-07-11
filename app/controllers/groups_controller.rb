class GroupsController < ReaderActionController
  helper :reader
  
  before_filter :require_reader
  before_filter :get_group_or_groups
  before_filter :require_group_visibility, :only => [:show]

  def index
    # respond to http request
    # respond to vcard request
    # respond to csv request
  end

  def show
    @readers = @group.readers
  end
    
private
  
  def get_group_or_groups
    @groups = Group.visible_to(current_reader)
    @group = @groups.find(params[:id]) if params[:id]
  end

  def require_group_visibility
    raise ReaderError::AccessDenied if @group && !@group.visible_to?(current_reader)
  end
  
end
