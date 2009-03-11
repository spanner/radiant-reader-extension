require File.dirname(__FILE__) + '/../spec_helper'

describe ReadersController do
  dataset :readers
  
  before do
    controller.stub!(:request).and_return(request)
    Page.current_site = sites(:test) if defined? Site
    request.env["HTTP_REFERER"] = 'http://test.host/referer!'
  end
    
  describe "with a get to new" do
    it "should render the registration screen" do
      get :new
      response.should be_success
      response.should render_template("new")
    end
    
    it "should generate a secret email field name" do
      
    end
  end
  
  describe "with a registration" do
    before do
      session[:email_field] = @email_field = 'randomstring'
      post :create, :reader => {:name => "registering user"}, :password => "password", :password_confirmation => "password", :randomstring => 'registrant@spanner.org'
      @reader = Reader.find_by_name('registering user')
    end
    
    it "should create a new reader" do
      @reader.should_not be_nil
    end

    it "should set the current reader" do
      controller.send(:current_reader).should == @reader
    end

    it "should have deobfuscated the email field" do
      @reader.email.should == 'registrant@spanner.org'
    end

    it "should have defaulted to email address as login" do
      @reader.login.should == @reader.email
    end
    
    if defined? Site
      it "should have assigned the new reader to the current site" do
        @reader.site.should == sites(:test)
      end
    end

    it "should redirect to activate" do
      response.should be_redirect
      response.should redirect_to(:action => 'activate')
    end
    
    describe "with the honeytrap field filled in" do
      before do
        session[:email_field] = @email_field = 'randomstring'
        post :create, :reader => {:name => "bot user", :email => 'registrant@spanner.org'}, :password => "password", :password_confirmation => "password"
        @reader = Reader.find_by_name('bot user')
      end
      it "should not create the reader" do
        @reader.should be_nil
      end
      it "should re-render the form" do
        response.should be_success
        response.should render_template('new')
      end
      it "should flash a notice" do
        flash[:error].should_not be_nil
      end
    end
  end

  it "should render the activation screen on get to activate" do
    get :activate
    response.should be_success
    response.should render_template("activate")
  end

  describe "with a correct activation" do
    before do
      @newreader = readers(:inactive)
      post :activate, :email => @newreader.email, :activation_code => @newreader.activation_code
      @reader = Reader.find_by_name('Inactive')
    end

    it "should activate the reader" do
      @reader.activated?.should be_true
      @reader.activated_at.should be_close((Time.now).utc, 1.minute) # sometimes specs are slow
    end

    it "should redirect to the self page" do
      response.should be_redirect
      response.should redirect_to(:action => 'show', :id => @newreader.id)
    end
  end

  describe "with an incorrect activation" do
    before do
      @newreader = readers(:inactive)
      post :activate, :email => @newreader.email, :activation_code => 'down periscope'
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
      @reader = readers(:normal)
      post :login, :reader => {:login => @reader.login, :password => "password"}
    end
    
    it "should redirect back" do
      response.should be_redirect
      response.should redirect_to('http://test.host/referer!')
    end

    it "should say hello" do
      flash[:notice].should =~ /Hello #{@reader.name}/
    end
  end
  
  describe "with an incorrect login" do
    it "should rerender the login template" do
      @reader = readers(:normal)
      post :login, :reader => {:login => @reader.login, :password => "wrongo"}
      response.should be_success
      response.should render_template("login")
      flash[:error].should_not be_nil
    end
  end
  
  it "should render the reset password screen on get to password" do
    get :password
    response.should be_success
    response.should render_template("password")
  end

  describe "with a reset password request" do
    it "should reject an unknown email address" do
      post :password, :email => "pope@spanner.org"
    end
    
    describe "with a recognised email address" do
      before do
        post :password, :email => 'normal@spanner.org'
        @reader = readers(:normal)
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
        post :password, :email => 'inactive@spanner.org'
        @reader = readers(:inactive)
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
      @reader = readers(:repasswording)
      @newpw = @reader.provisional_password
    end

    describe "that is correct" do
      before do
        post :repassword, :id => @reader.id, :activation_code => @reader.activation_code
        @reader = Reader.find_by_name('Repasswording')
      end
    
      it "should reset the password" do
        @reader.password.should == @reader.sha1(@newpw)
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
        @reader.password.should_not == @reader.sha1(@newpw)
      end

      it "should redirect to the password form" do
        response.should be_redirect
        response.should redirect_to(:action => 'password')
      end

      it "should flash an error" do
        response.should be_redirect
        response.should redirect_to(:action => 'password')
        flash[:error].should =~ /activation code/
      end
    end
  end
  
  describe "to the browser" do
    describe "who has logged in" do
      before do
        login_as_reader(:normal)
      end
  
      it "should show another reader page" do 
        get :show, :id => reader_id(:visible)
        response.should be_success
        response.should render_template("show")
      end

      if defined? Site
        it "should raise a Not Found error when asked for a reader from another site" do 
          lambda { 
            get :show, :id => reader_id(:elsewhere) 
          }.should raise_error(ActiveRecord::RecordNotFound)
        end
      end
      
      it "should refuse to show the edit page for another reader" do 
        get :edit, :id => reader_id(:visible)
        response.should be_success
        flash[:error].should =~ /another person/
      end

      it "should not remove this reader" do 
        delete :destroy, :id => reader_id(:normal)
        response.should be_redirect
        response.should redirect_to(admin_readers_url)
        Reader.find(reader_id(:normal)).should_not be_nil
      end

      it "should not remove another reader" do 
        delete :destroy, :id => reader_id(:visible)
        response.should be_redirect
        response.should redirect_to(admin_readers_url)
        Reader.find(reader_id(:visible)).should_not be_nil
      end
    end

    describe "who has not logged in" do
      before do
        logout_reader
      end
  
      it "should not show a reader page" do 
        get :show, :id => reader_id(:visible)
        response.should be_redirect
        response.should redirect_to(:action => 'login')
      end
    end
  end
    
  describe "with an update request" do
    before do
      login_as_reader(:normal)
    end

    describe "that includes the correct password" do
      before do
        put :update, {:id => reader_id(:normal), :reader => {:name => "New Name"}, :current_password => 'password'}
        @reader = readers(:normal)
      end
      
      it "should update the reader" do 
        @reader.name.should == 'New Name'
      end

      it "should redirect to the reader page" do 
        response.should be_redirect
        response.should redirect_to(:action => 'show', :id => @reader.id)
      end
      
    end

    describe "that does not include the correct password" do
      before do
        put :update, {:id => reader_id(:normal), :reader => {:name => "New Name"}, :current_password => 'wrongo'}
        @reader = readers(:normal)
      end

      it "should not update the reader" do 
        @reader.name.should == 'Normal'
      end

      it "should re-render the edit form" do 
        response.should be_success
        response.should render_template("edit")
      end
    end

    describe "that does not validate" do
      before do
        put :update, {:id => reader_id(:normal), :reader => {:login => "visible@spanner.org"}, :current_password => 'password'}
        @reader = readers(:normal)
      end

      it "should not update the reader" do 
        @reader.name.should == 'Normal'
      end

      it "should re-render the edit form" do 
        response.should be_success
        response.should render_template("edit")
      end

    end
  end
end
