require File.dirname(__FILE__) + '/../spec_helper'

describe ReadersController do
  dataset :readers
  
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
      
    it "should activate the reader posting the right confirmation code" do

    end

    it "should redirect to activation the reader posting the wrong confirmation code" do

    end

    it "should redirect to self the reader already activated" do

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

  it "should render the registration screen on get to new" do
    get :new
    response.should be_success
    response.should render_template("new")
  end

  it "should render the activation screen on get to activate" do
    get :activate
    response.should be_success
    response.should render_template("activate")
  end


  it "should render the reset password screen on get to password" do
    get :password
    response.should be_success
    response.should render_template("password")
  end

  describe "with a reset password request" do
    before do
      post :password, :reader => {:email => "normal@spanner.org"}
    end

    it "should reject an unknown email address" do
      
    end

    it "should create a provisional password for an active reader " do

    end

    it "should resend the activation message to an inactive reader" do

    end

    it "should reset the password of the reader posting the right repassword activation code" do
      
    end

    it "should refuse and redirect the reader posting the wrong repassword activation code" do
      
    end
  end

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

  it "should refuse to update a reader who is not logged in" do 
    
  end

  it "should refuse to update a reader who does not supply the correct password" do 
    
  end

  it "should update a reader who is logged in and supplies the correct password" do 
    
  end

end
