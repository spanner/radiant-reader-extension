require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::MessagesController do
  dataset :messages
  
  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle Messages" do
    controller.class.model_class.should == Message
  end
  
  describe "on index" do
    before do
      login_as :existing
    end
    
    it "should redirect to the settings page" do
      get :index
      response.should be_redirect
      response.should redirect_to(admin_reader_settings_url)
    end
  end

  describe "on update" do
    before do
      login_as :existing
    end
    
    it "should redirect to the settings page" do
      put :update, :id => message_id(:normal), :subject => 'testing'
      response.should be_redirect
      response.should redirect_to(admin_reader_settings_url)
    end
  end
  
end
