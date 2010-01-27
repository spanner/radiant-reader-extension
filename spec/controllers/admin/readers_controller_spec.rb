require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::ReadersController do
  dataset :users
  dataset :readers
  
  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle Readers" do
    controller.class.model_class.should == Reader
  end
end
