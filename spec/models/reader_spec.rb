require File.dirname(__FILE__) + '/../spec_helper'

describe Reader do
  dataset :messages
  dataset :reader_layouts
  activate_authlogic
  
  before do
    @existing_reader = readers(:normal)
  end
  
  describe "on validation" do
    before do
      @reader = Reader.new :name => "Test Reader", :email => 'test@spanner.org', :login => 'test', :password => 'password', :password_confirmation => 'password'
      @reader.should be_valid
    end
    
    it "should require a name" do
      @reader.name = nil
      @reader.should_not be_valid
      @reader.errors.on(:name).should_not be_empty
    end
  
    it "should require a valid email address" do
      @reader.email = nil
      @reader.should_not be_valid
      @reader.errors.on(:email).should_not be_empty
      @reader.email = 'nodomain'
      @reader.should_not be_valid
      @reader.email = 'bad@punctuation,com'
      @reader.should_not be_valid
    end

    it "should require an email address that is not in use by either reader or user" do
      @reader.email = readers(:normal).email
      @reader.should_not be_valid
      @reader.email = users(:another).email
      @reader.should_not be_valid
    end
  
    it "should require a unique login" do
      @reader.login = @existing_reader.login
      @reader.should_not be_valid
      @reader.errors.on(:login).should_not be_empty
    end
  end
  
  describe "on creation" do
    before do
      @reader = Reader.create :name => "Test Reader", :email => 'test@spanner.org', :login => 'test', :password => 'password', :password_confirmation => 'password'
    end
      
    it 'should await activation' do
      @reader.activated_at.should be_nil
      @reader.activated?.should be_false
    end
    
    it 'should default to trusted status' do
      @reader.trusted.should == true
    end
  end
  
  describe "on create_for_user" do
    it "should return the existing reader if there is one" do
      reader = Reader.find_or_create_for_user(users(:existing))
      reader.should == readers(:user)
      reader.is_user?.should be_true
      reader.is_admin?.should be_false
    end

    it "should create a matching reader if necessary" do
      user = users(:admin)
      reader = Reader.find_or_create_for_user(user)
      [:name, :email, :login, :created_at, :notes].each do |att|
        reader.send(att).should == user.send(att)
      end
      reader.crypted_password.should == user.password
      ReaderSession.new(:login => 'admin', :password => 'password').should be_valid
      reader.is_user?.should be_true
      reader.is_admin?.should be_true
    end
  end
  
  describe "on update" do
    before do
      @reader = readers(:normal)
    end
    
    it 'should be puttable in the doghouse' do
      @reader.password_confirmation = @reader.password = ''
      @reader.trusted = false
      @reader.save!
      @reader.trusted.should == false
    end
  end
  
  describe "on update if really a user" do
    
    it "should update the user's attributes" do
      reader = readers(:user)
      reader.name = "Cardinal Fang"
      reader.save!
      
      User.find_by_name("Cardinal Fang").should == users(:existing)
    end
    
    it "should update the user's credentials" do
      reader = readers(:user)
      reader.password = reader.password_confirmation = 'blotto'
      reader.save!
      ReaderSession.new(:login => reader.login, :password => 'blotto').should be_valid
      reader.user.authenticated?('blotto').should be_true
    end
  end
  
  describe "on activation" do
    before do
      @reader = Reader.create :name => "Test Reader", :email => 'test@spanner.org', :login => 'another_login', :password => 'password', :password_confirmation => 'password', :trusted => 1
    end
    
    it 'should be retrieved by id and activation code' do
      Reader.find_by_id_and_perishable_token(@reader.id, @reader.perishable_token).should == @reader
    end

    it 'should not be retrievable with no or the wrong code' do
      Reader.find_by_id_and_perishable_token(@reader.id, 'walrus').should be_nil
      Reader.find_by_id_and_perishable_token(@reader.id, '').should be_nil
    end

    it 'should activate itself' do
      @reader.activate!
      @reader.activated?.should be_true
      @reader.activated_at.should_not be_nil
    end
  end
  
  describe "on login" do
    before do
      @reader = Reader.create :name => "Test Reader", :email => 'test@spanner.org', :login => 'test', :password => 'hoohaa', :password_confirmation => 'hoohaa'
      @reader.activate!
    end
    
    it 'should authenticate' do
      ReaderSession.new(:login => 'test', :password => 'hoohaa').should be_valid
    end
  
    it 'should not authenticate with bad password' do
      ReaderSession.new(:login => 'test', :password => 'corcovado').should_not be_valid
    end
  
    it 'should not authenticate if it does not exist' do
      ReaderSession.new(:login => 'loch ness monster', :password => 'blotto').should_not be_valid
    end
  end
end
