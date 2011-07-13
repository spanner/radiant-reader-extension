require File.dirname(__FILE__) + '/../spec_helper'

describe ReaderActivationsController do
  dataset :readers
  
  before do
    controller.stub!(:request).and_return(request)
    Page.current_site = sites(:test) if defined? Site
    request.env["HTTP_REFERER"] = 'http://test.host/referer!'
  end

  describe "with a correct activation" do
    before do
      @newreader = readers(:inactive)
      put :update, :id => @newreader.id, :activation_code => @newreader.perishable_token
      @reader = Reader.find_by_name('Inactive')
    end

    it "should activate the reader" do
      @reader.activated?.should be_true
      @reader.activated_at.should be_close((Time.now).utc, 1.minute)
    end

    it "should redirect to the dashboard" do
      response.should be_redirect
      response.should redirect_to(dashboard_url)
    end
  end

  describe "with an incorrect activation" do
    before do
      @newreader = readers(:inactive)
      put :update, :id => @newreader.id, :activation_code => 'down perishcope'
    end
    
    it "should render the show page" do
      response.should be_success
      response.should render_template("show")
    end

    it "should not flash an error" do
      flash[:error].should be_nil
    end
  end

end
