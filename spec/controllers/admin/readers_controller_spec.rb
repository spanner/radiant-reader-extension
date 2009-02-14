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

  { 
    :get => [:index, :new, :edit, :remove],
    :post => [:create],
    :put => [:update],
    :delete => [:destroy] 
  }.each do |method, actions|
    actions.each do |action|
      it "should require login to access the #{action} action" do
        logout
        lambda { send(method, action, :id => reader_id(:normal)).should require_login }
      end

      it "should allow you to access to #{action} action if you are an admin" do
        lambda { 
          send(method, action, :id => reader_id(:normal)) 
        }.should restrict_access(:allow => users(:admin),
                                 :url => '/admin/page')
      end
      
      it "should deny you access to #{action} action if you are not an admin" do
        lambda { 
          send(method, action, :id => reader_id(:normal)) 
        }.should restrict_access(:deny => [users(:developer), users(:existing)],
                                 :url => '/admin/page')
      end
    end
  end
end
