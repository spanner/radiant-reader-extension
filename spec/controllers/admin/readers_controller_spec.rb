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
    :get => [:new, :edit],
    :post => [:create], #omitted because failure and success look the same to restrict_access 
    :put => [:update], #omitted because failure and success look the same to restrict_access 
    :delete => [:destroy]
  }.each do |method, actions|
    actions.each do |action|
      it "should require login to access the #{action} action" do
        logout
        lambda { send(method, action, :id => reader_id(:normal)).should require_login }
      end

      it "should allow you access to the #{action} action if you are an admin" do
        lambda { 
          send(method, action, :id => reader_id(:normal)) 
        }.should restrict_access(:allow => users(:admin), :url => '/admin/pages')
      end
      
      it "should deny you access to the #{action} action if you are not an admin" do
        lambda { 
          send(method, action, :id => reader_id(:normal)) 
        }.should restrict_access(:deny => [users(:developer), users(:existing)], :url => '/admin/pages')
      end
    end
  end
  
  { 
    :get => [:index],
  }.each do |method, actions|
    actions.each do |action|
      it "should allow you to access to #{action} action even if you are not an admin" do
        lambda { 
          send(method, action, :id => reader_id(:normal)) 
        }.should restrict_access(:allow => [users(:developer), users(:admin), users(:existing)], :url => '/admin/pages')
      end
    end
  end
end
