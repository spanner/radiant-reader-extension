require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController do
  dataset :readers
  
  before do
    controller.stub!(:request).and_return(request)
    Page.current_site = sites(:test) if defined? Site
    request.env["HTTP_REFERER"] = 'http://test.host/referer!'
    Radiant::Config['reader.allow_registration?'] = true
  end
    
  describe "with a get to new" do
    before do
      @reader = Reader.new
      Reader.stub!(:new).and_return(@reader)
    end
    
    it "should render the registration screen" do
      get :new
      response.should be_success
      response.should render_template("new")
    end
    
    it "should generate a secret email field name" do
      newreader = Reader.new
      Reader.stub!(:new).and_return(newreader)
      Authlogic::Random.should_receive(:friendly_token).at_least(:once).and_return("hello_dolly")
      get :new
      newreader.email_field.should == "hello_dolly"
      session[:email_field].should == "hello_dolly"
    end
  end
  
  describe "listing readers" do
    it "should respond to csv requests"
    it "should respond to vcard requests"
  end
  
  describe "with a registration" do
    describe "that validates" do
      before do
        session[:email_field] = 'gibberish'
        post :create, :reader => {:name => "registering user", :password => "password", :password_confirmation => "password"}, :gibberish => 'registrant@spanner.org'
        @newreader = Reader.find_by_name("registering user")
      end
      it "should create a new reader" do
        @newreader.should_not be_nil
        @newreader.new_record?.should be_false
        @newreader.should be_valid
      end

      it "should set the current reader" do
        controller.send(:current_reader).should == @newreader
      end

      it "should have deobfuscated the email field" do
        @newreader.email.should == 'registrant@spanner.org'
      end

      it "should redirect to the please-activate page" do
        response.should be_redirect
        response.should redirect_to(reader_activation_url)
      end
    end
    
    describe "that does not validate" do
      before do
        session[:email_field] = 'gibberish'
        @newreader = Reader.new
        Reader.stub!(:new).and_return(@newreader)
        post :create, :reader => {:name => "registering user", :password => "password", :password_confirmation => "passwrd"}, :gibberish => 'registrant@spanner.org'
      end
      
      it "should not create the user" do
        @newreader.new_record?.should be_true
      end

      it "should not set the current reader" do
        controller.send(:current_reader).should be_nil
      end

      it "should return to the registration form" do
        response.should be_success
        response.should render_template('new')
      end
      
      it "should set validation error messages" do
        @newreader.errors.should_not be_empty
        @newreader.errors.on(:password).should_not be_empty
      end
    end
    
    describe "with the trap field filled in" do
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
  
  describe "to the browser" do
    describe "who has logged in" do
      before do
        activate_authlogic
        rsession = ReaderSession.create!(readers(:normal))
        # controller.stub!(:current_reader_session).and_return(rsession)
      end
  
      it "should route '/account' to my account" do
        params_from(:get, '/account').should == {:controller => 'accounts', :action => 'edit'}
      end

      it "should route '/profile' to my account" do
        params_from(:get, '/profile').should == {:controller => 'accounts', :action => 'show'}
      end

      it "should consent to show another reader page" do 
        get :show, :id => reader_id(:visible)
        response.should be_success
      end
      
      it "should not show the edit page for another reader" do 
        get :edit, :id => reader_id(:visible)
        response.should be_success        
        flash[:error].should =~ /other people's accounts/
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
        response.should redirect_to(reader_login_url)
      end
    end
  end
    
  describe "with an update request" do
    before do
      login_as_reader(:normal)
    end

    describe "that is valid" do
      before do
        put :update, {:id => reader_id(:normal), :reader => {:name => "New Name"}}
        @reader = readers(:normal)
      end
      
      it "should update the reader" do 
        @reader.name.should == 'New Name'
      end

      it "should redirect to the reader page" do 
        response.should be_redirect
        response.should redirect_to(dashboard_url)
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
  
  describe "when registration is not allowed" do
    before do
      Radiant::Config['reader.allow_registration?'] = false
    end
    
    it "should not offer the registration form" do
      get :new
      response.should be_redirect
      response.should redirect_to reader_login_url
      flash[:error].should_not be_nil
    end
  end
end
