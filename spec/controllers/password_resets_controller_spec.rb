require File.dirname(__FILE__) + '/../spec_helper'

describe PasswordResetsController do
  dataset :readers, :messages
  
  before do
    controller.stub!(:request).and_return(request)
    Page.current_site = sites(:test) if defined? Site
    request.env["HTTP_REFERER"] = 'http://test.host/referer!'
  end
    
  describe "with a forgot-my-password request" do
    it "should ask for an email address" do
      get :new
      response.should be_success
      response.should render_template("new")
    end
  end
  
  describe "with a submitted email address" do
    describe "that we recognise" do
      before do
        post :create, :email => 'normal@spanner.org'
        @reader = readers(:normal)
      end
      
      it "should give instructions" do
        response.should be_success
        response.should render_template("create")
      end
    end
    
    describe "that we don't recognise" do
      before do
        post :create, :email => 'abinormal@spanner.org'
      end
      
      it 'should grumble' do
        response.should be_success
        response.should render_template("new")
        flash[:error].should_not be_blank
      end
      it 'should not send a message' do
        ActionMailer::Base.deliveries.last.should be_nil
      end
      
    end
  end

  describe "with a confirmation" do
    describe "where the code is correct" do
      before do
        @reader = readers(:normal)
        get :edit, :id => @reader.id, :confirmation_code => @reader.perishable_token
      end
      
      it 'should show the new-password form' do
        response.should be_success
        response.should render_template("edit")
        flash[:error].should be_nil
      end
    end
    
    describe "where the code is wrong" do
      before do
        @reader = readers(:normal)
        get :edit, :id => @reader.id, :confirmation_code => 'anyoldstringwillnotdo'
      end
      it 'should grumble' do
        response.should be_success
        response.should render_template("edit")
        flash[:error].should_not be_blank
      end
    end
  end

  describe "with a new password" do
    
    describe "where the confirmation code is correct and the password confirmed" do
      before do
        reader = readers(:normal)
        post :update, :id => reader.id, :confirmation_code => reader.perishable_token, :reader => {:password => 'testify', :password_confirmation => 'testify'}
      end

      it "should update the reader" do
        readers(:normal).valid_password?('testify').should be_true
      end

      it "should log the reader in" do
        controller.send(:current_reader).should == readers(:normal)
      end
    end

    describe "where the confirmation code is correct but the password not confirmed" do
      before do
        @reader = readers(:normal)
        post :update, :id => @reader.id, :confirmation_code => @reader.perishable_token, :reader => {:password => 'testify', :password_confirmation => 'testy'}
      end

      it 'should grumble' do
        flash[:error].should_not be_blank
      end

      it "should return the password form again" do
        response.should be_success
        response.should render_template("edit")
      end
    end
    
    describe "where the confirmation code is wrong" do
      before do
        @reader = readers(:normal)
        post :update, :id => @reader.id, :confirmation_code => 'dingbat', :reader => {:password => 'testify', :password_confirmation => 'testify'}
      end

      it 'should grumble' do
        response.should be_success
        response.should render_template("edit")
        flash[:error].should_not be_blank
      end

      it 'should not change the password' do
        readers(:normal).valid_password?('testify').should be_false
      end
    end
  end
end
