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

    it "should redirect to a confirmation page" do
      response.should be_redirect
    end
  end

  describe "with an incorrect activation" do
    before do
      @newreader = readers(:inactive)
      put :update, :email => @newreader.email, :activation_code => 'down perishcope'
    end
    
    it "should render the please-activate page" do
      response.should be_success
      response.should render_template("show")
    end

    it "should flash an error" do
      flash[:error].should_not be_nil
    end
  end

end
