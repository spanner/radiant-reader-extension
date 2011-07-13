class GroupsController < ReaderActionController
  helper :reader
  
  before_filter :require_reader
  before_filter :get_group_or_groups
  before_filter :require_group_visibility, :only => [:show]

  def index
  end

  def show
    @readers = @group.readers.uniq
    respond_to do |format|
      format.html
      format.csv {
        send_data generate_csv(@readers), :type => 'text/csv; charset=utf-8; header=present', :filename => "#{@group.filename}.csv"
      }
      format.vcard {
        send_data @readers.map(&:vcard).join("\n"), :filename => "#{@group.filename}.vcf"	
      }
    end
  end
    
private
  
  def get_group_or_groups
    @groups = Group.visible_to(current_reader)
    @group = @groups.find(params[:id]).first if params[:id]
  end

  def require_group_visibility
    raise ReaderError::AccessDenied if @group && !@group.visible_to?(current_reader)
  end
  
end
