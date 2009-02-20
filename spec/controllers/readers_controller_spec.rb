require File.dirname(__FILE__) + '/../spec_helper'
ActionMailer::Base.delivery_method = :test  
ActionMailer::Base.perform_deliveries = true  
ActionMailer::Base.deliveries = []  

describe ReadersController do
  dataset :reader_sites
  dataset :readers
  dataset :reader_layouts
  
  before do
    controller.stub!(:request).and_return(request)
    controller.set_current_site
  end
    
  it "should render the registration screen on get to new" do
    get :new
    response.should be_success
    response.should render_template("new")
  end
  
  describe "with a registration" do
    before do
      post :create, :reader => {:name => "registering user", :email => 'registrant@spanner.org'}, :password => "password", :password_confirmation => "password"
      @reader = Reader.find_by_name('registering user')
    end
    
    it "should create a new reader" do
      @reader.should_not be_nil
    end

    it "should set the current reader" do
      controller.send(:current_reader).should == @reader
    end

    it "should have defaulted to email address as login" do
      @reader.login.should == @reader.email
    end

    it "should have assigned the new reader to the current site" do
      @reader.site.should == sites(:test)
    end

    it "should redirect to activate" do
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
      post :create, {:reader => {:name => "activating user", :email => 'activating@spanner.org'}, :password => "password", :password_confirmation => "password"}
      @newreader = Reader.find_by_name('activating user')
      post :activate, :email => @newreader.email, :activation_code => @newreader.activation_code
      @reader = Reader.find_by_name('activating user')
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
      request.env["HTTP_REFERER"] = 'http://test.host/referer!'
      post :create, {:reader => {:name => "wrongly activating user", :email => 'notactivating@spanner.org'}, :password => "password", :password_confirmation => "password"}
      @reader = Reader.find_by_name('wrongly activating user')
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
      post :create, :reader => {:name => "logging in user", :email => 'loggingin@spanner.org'}, :password => "password", :password_confirmation => "password"
      @reader = Reader.find_by_email('loggingin@spanner.org')
      post :login, :reader => {:login => "loggingin@spanner.org", :password => "password"}
    end
    
    it "should set the current reader" do
      controller.send(:current_reader).should == @reader
    end

    it "should redirect back" do
      response.should be_redirect
      response.should redirect_to('http://test.host/referer!')
    end
  end
  
  describe "with an incorrect login" do
    it "should render the login template" do
      post :login, :reader => {:login => "normal", :password => "wrong"}
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
        post :create, :reader => {:name => "passwording user", :email => 'pwing@spanner.org'}, :password => "password", :password_confirmation => "password"
        reader = Reader.find_by_name('passwording user')
        post :activate, :email => reader.email, :activation_code => reader.activation_code
        post :password, :email => reader.email
        @reader = Reader.find_by_name('passwording user')
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
        post :create, :reader => {:name => "inactive user", :email => 'notactivated@spanner.org'}, :password => "password", :password_confirmation => "password"
        @reader = Reader.find_by_name('inactive user')
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
      post :create, {:reader => {:name => "repasswording user", :email => 'repasswording@spanner.org'}, :password => "password", :password_confirmation => "password"}
      reader = Reader.find_by_name('repasswording user')
      post :activate, :email => reader.email, :activation_code => reader.activation_code
      post :password, :email => reader.email
      @reader = Reader.find_by_name('repasswording user')
      @newpw = @reader.provisional_password
    end

    describe "that is correct" do
      before do
        post :repassword, :id => @reader.id, :activation_code => @reader.activation_code
        @reader = Reader.find_by_name('repasswording user')
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
    describe "who has logged in" do
      before do
        login_as_reader(:normal)
      end
  
      it "should show another reader page" do 
        get :show, :id => reader_id(:idle)
        response.should be_success
        response.should render_template("show")
      end

      it "should raise a Not Found error when asked for a reader from another site" do 
        lambda { 
          get :show, :id => reader_id(:othersite) 
        }.should raise_error(ActiveRecord::RecordNotFound)
      end

      it "should refuse to show the edit page for another reader" do 
        get :edit, :id => reader_id(:idle)
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
        delete :destroy, :id => reader_id(:idle)
        response.should be_redirect
        response.should redirect_to(admin_readers_url)
        Reader.find(reader_id(:idle)).should_not be_nil
      end
    end

    describe "who has not logged in" do
      before do
        logout_reader
      end
  
      it "should not show a reader page" do 
        get :show, :id => reader_id(:idle)
        response.should be_redirect
        response.should redirect_to(:action => 'login')
      end
    end
  end
    
  describe "with an update request" do
    before do
      request.env["HTTP_REFERER"] = 'http://test.host/referer!'
      post :create, {:reader => {:name => "newuser", :email => 'newuser@spanner.org'}, :password => "password", :password_confirmation => "password"}
      @reader = Reader.find_by_email('newuser@spanner.org')
      post :login, :reader => {:login => "newuser@spanner.org", :password => "password"}
    end

    describe "that includes the correct password" do
      before do
        put :update, {:id => @reader.id, :reader => {:name => "New Name"}, :current_password => 'password'}
        @reader = Reader.find_by_email('newuser@spanner.org')
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
        put :update, {:id => @reader.id, :reader => {:name => "New Name"}, :current_password => 'wrongo'}
        # @reader.reload
      end

      it "should not update the reader" do 
        @reader.name.should == 'newuser'
      end

      it "should rerender the edit form" do 
        response.should be_success
        response.should render_template("edit")
      end

    end

    describe "that does not validate" do
      before do
        put :update, {:id => @reader.id, :reader => {:name => "New Name", :login => 'I'}, :current_password => 'password'}
        @reader = Reader.find_by_email('newuser@spanner.org')
      end

      it "should not update the reader" do 
        @reader.name.should == 'newuser'
      end

      it "should rerender the edit form" do 
        response.should be_success
        response.should render_template("edit")
      end

    end
  end
end
