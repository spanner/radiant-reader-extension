require File.dirname(__FILE__) + '/../spec_helper'
ActionMailer::Base.delivery_method = :test  
ActionMailer::Base.perform_deliveries = true  
ActionMailer::Base.deliveries = []  

describe ReadersController do
  dataset :readers

  it "should render the registration screen on get to new" do
    get :new
    response.should be_success
    response.should render_template("new")
  end
  
  describe "with a registration" do
    before do
      post :create, :reader => {:name => "newuser", :email => 'newuser@spanner.org'}, :password => "password", :password_confirmation => "password"
      @reader = Reader.find_by_name('newuser')
    end
    
    it "should create a new user" do
      @reader.should_not be_nil
    end

    it "should set the current reader" do
      controller.send(:current_reader).should == @reader
    end

    it "should default to email address as login" do
      @reader.login.should == @reader.email
    end

    it "should redirect to activate when register is successful" do
      response.should be_redirect
      response.should redirect_to(:action => 'activate')
    end
      
  end

  it "should render the activation screen on get to activate" do
    get :activate
    response.should be_success
    response.should render_template("activate")
  end

  describe "with a correct activation" do
    before do
      request.env["HTTP_REFERER"] = 'http://test.host/referer!'
      post :create, :reader => {:name => "newuser", :email => 'newuser@spanner.org'}, :password => "password", :password_confirmation => "password"
      @reader = Reader.find_by_name('newuser')
      post :activate, :email => @reader.email, :activation_code => @reader.activation_code
      @reader.reload
    end

    it "should activate the reader" do
      @reader.activated?.should be_true
      @reader.activated_at.should be_close((Time.zone.now).utc, 1.minute) # sometimes specs are slow
    end

    it "should redirect to the self page" do
      response.should be_redirect
      response.should redirect_to(:action => 'show', :id => @reader.id)
    end
  end

  describe "with an incorrect activation" do
    before do
      request.env["HTTP_REFERER"] = 'http://test.host/referer!'
      post :create, :reader => {:name => "newuser", :email => 'newuser@spanner.org'}, :password => "password", :password_confirmation => "password"
      @reader = Reader.find_by_name('newuser')
      post :activate, :email => @reader.email, :activation_code => 'down periscope'
    end
    
    it "should rerender the activation form" do
      response.should render_template("activate")
    end

    it "should flash an appropriate error message" do
      flash[:error].should =~ /Unable to activate/
    end
  end

  it "should render the login screen on get to login" do
    get :login
    response.should be_success
    response.should render_template("login")
  end

  describe "with a correct login" do
    before do
      request.env["HTTP_REFERER"] = 'http://test.host/referer!'
      post :create, :reader => {:name => "newuser", :email => 'newuser@spanner.org'}, :password => "password", :password_confirmation => "password"
      @reader = Reader.find_by_email('newuser@spanner.org')
      post :login, :reader => {:login => "newuser@spanner.org", :password => "password"}
    end
    
    it "should set the current reader" do
      controller.send(:current_reader).should == @reader
    end

    it "should redirect back" do
      response.should be_redirect
      response.should redirect_to('http://test.host/referer!')
    end
  end
  
  it "should render the login template when login fails" do
    post :login, :reader => {:login => "normal", :password => "wrong"}
    response.should render_template("login")
    flash[:error].should_not be_nil
  end

  it "should render the reset password screen on get to password" do
    get :password
    response.should be_success
    response.should render_template("password")
  end

  describe "with a reset password request" do
    it "should reject an unknown email address" do
      post :password, :email => "normal@spanner.org"
      
    end
    
    describe "that is recognised" do
      before do
        post :create, :reader => {:name => "newuser", :email => 'newuser@spanner.org'}, :password => "password", :password_confirmation => "password"
        @reader = Reader.find_by_name('newuser')
        post :activate, :email => @reader.email, :activation_code => @reader.activation_code
        @reader.reload
        post :password, :email => @reader.email
        @reader.reload
      end

      it "should create a provisional password" do
        @reader.provisional_password.should_not be_nil
      end
      
      it "should send a repassword notification" do
        message = ActionMailer::Base.deliveries.last
        message.should_not be_nil
        message.subject.should =~ /password/
      end
    end

    describe "that is for an account not yet activated" do
      before do
        post :create, :reader => {:name => "newuser", :email => 'newuser@spanner.org'}, :password => "password", :password_confirmation => "password"
        @reader = Reader.find_by_name('newuser')
        post :password, :email => @reader.email
      end

      it "should not create a provisional password" do
        @reader.provisional_password.should be_nil
      end

      it "should resend the activation message" do
        message = ActionMailer::Base.deliveries.last
        message.should_not be_nil
        message.subject.should =~ /activate/
      end
    end
  end
  
  describe "with a reset password confirmation" do
    before do
      post :create, :reader => {:name => "newuser", :email => 'newuser@spanner.org'}, :password => "password", :password_confirmation => "password"
      @reader = Reader.find_by_name('newuser')
      post :activate, :email => @reader.email, :activation_code => @reader.activation_code
      @reader.reload
      post :password, :email => @reader.email
      @reader.reload
      @newpw = @reader.provisional_password
    end

    describe "that is correct" do
      before do
        post :repassword, :id => @reader.id, :activation_code => @reader.activation_code
        @reader.reload
      end
    
      it "should reset the password" do
        @reader.authenticated?(@newpw).should be_true
      end

      it "should clear away the provisional and activation clutter" do
        @reader.provisional_password.should be_nil
        @reader.activation_code.should be_nil
      end

    end

    describe "that is not correct" do
      before do
        post :repassword, :id => @reader.id, :activation_code => 'dive dive dive'
      end

      it "should not reset the password" do
        @reader.password.should_not == @newpw
      end

      it "should redirect to the password form" do
        response.should be_redirect
        response.should redirect_to(:action => 'password')
      end

      it "should flash a sensible error" do
        response.should be_redirect
        response.should redirect_to(:action => 'password')
        flash[:error].should =~ /activation code/
      end
    end
  end
  
  describe "to the browser" do
  
    it "should show a reader page to a logged-in reader" do 
    
    end

    it "should show a reader page to a logged-in user" do 
    
    end

    it "should refuse to show a reader page to an anonymous visitor" do 
    
    end

    it "should refuse to show the reader list" do 
    
    end

    it "should refuse to remove a reader" do 
    
    end

    it "should refuse to show the edit page for another reader" do 
    
    end

  end
  
  describe "with an update request" do

    it "should refuse to update a reader who is not logged in" do 
    
    end

    it "should refuse to update a reader who does not supply the correct password" do 
    
    end

    it "should update a reader who is logged in and supplies the correct password" do 
    
    end
  end
end
