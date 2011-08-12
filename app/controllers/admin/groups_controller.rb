class Admin::GroupsController < Admin::ResourceController
  helper :reader
  paginate_models
  skip_before_filter :load_model
  before_filter :load_model, :except => :index    # we want the filter to run before :show too
  
  def show
    
  end
  
  def load_models
    self.models = paginated? ? model_class.roots.paginate(pagination_parameters) : model_class.roots.all
  end
  
  def load_model
    self.model = if params[:id]
      model_class.find(params[:id])
    else
      model_class.new(:parent_id => params[:parent_id])
    end
  end
  
end
