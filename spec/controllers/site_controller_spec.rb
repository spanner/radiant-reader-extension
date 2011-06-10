require File.dirname(__FILE__) + '/../spec_helper'

describe SiteController do
  dataset :readers
  
  before do
    controller.stub!(:request).and_return(request)
    Page.current_site = sites(:test) if defined? Site
    request.env["HTTP_REFERER"] = 'http://test.host/referer!'
  end
    
  describe "with no reader" do
    before do
      logout_reader
    end
    
    describe "getting an ungrouped page" do
      it "should render the page" do
        get :show_page, :url => ''
        response.should be_success
        response.body.should == 'Hello world!'
      end
    end
    
    describe "getting a grouped page" do
      it "should redirect to login" do
        get :show_page, :url => 'parent/'
        response.should be_redirect
        response.should redirect_to(reader_login_url)
      end
    end
  end
  
  describe "with a reader" do
    before do
      login_as_reader(:normal)
    end

    describe "getting an ungrouped page" do
      it "should render the page" do
        get :show_page, :url => ''
        response.should be_success
        response.body.should == 'Hello world!'
      end
    end
    
    describe "getting a grouped page to which she has access" do
      it "should render the page" do
        get :show_page, :url => 'parent/'
        response.should be_success
        response.body.should == 'Parent body.'
      end
    end
    
    describe "getting a grouped page to which she doesn't have access" do
      it "should redirect to the permission-denied page" do
        get :show_page, :url => 'news/'
        response.should be_redirect
        response.should redirect_to(reader_permission_denied_url)
      end
    end
  end
end
