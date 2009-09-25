require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::MessagesController do
  dataset :messages
  
  it "should be a ResourceController" do
    controller.should be_kind_of(Admin::ResourceController)
  end

  it "should handle Messages" do
    controller.class.model_class.should == Message
  end

  describe "on preview" do
    before do
      login_as :existing
    end
    
    it "should render a bare message" do
      get :preview, :id => message_id(:taggy)
      response.should be_success
      response.should render_template('preview')
      response.layout.should == nil
    end

  end
  
  describe "on deliver" do
    before do
      login_as :existing
    end
    
    it "should trigger a sending" do
      message = messages(:taggy)
      Message.should_receive(:find).at_least(:once).and_return(message)
      message.should_receive(:deliver).once
      get :deliver, :id => message_id(:taggy), :delivery => 'all'
      response.should be_redirect
      response.should redirect_to(admin_message_url(messages(:taggy)))
    end
  end
  
  describe "on update (and create)" do
    before do
      login_as :existing
    end
    
    it "should redirect to show the updated object" do
      put :update, :id => message_id(:normal), :subject => 'testing'
      response.should be_redirect
      response.should redirect_to(admin_message_path(message_id(:normal)))
    end
  end
  
end
