class Admin::GroupsController < Admin::ResourceController
  skip_before_filter :load_model
  before_filter :load_model, :except => :index    # we want the filter to run before :show too
  
  def show
    
  end
end
