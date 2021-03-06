require File.dirname(__FILE__) + '/../spec_helper'

describe Reader do
  dataset :readers
  activate_authlogic
  
  before do
    @existing_reader = readers(:normal)
  end
  
  it "should have some groups" do
    reader = readers(:normal)
    reader.groups.any?.should be_true
  end
  
  describe "on validation" do
    before do
      @reader = Reader.new :name => "Test Reader", :email => 'test@spanner.org', :nickname => 'test', :password => 'passw0rd', :password_confirmation => 'passw0rd'
      @reader.should be_valid
    end
    
    it "should require (but derive) a name" do
      @reader.name = nil
      @reader.should be_valid
      @reader.forename = @reader.surname = @reader.name = nil
      @reader.should_not be_valid
      @reader.errors.on(:name).should_not be_empty
      @reader.forename = "very"
      @reader.surname = "testy"
      @reader.should be_valid
      @reader.name.should == "very testy"
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
  
    it "should require a unique nickname" do
      @reader.nickname = @existing_reader.nickname
      @reader.should_not be_valid
      @reader.errors.on(:nickname).should_not be_empty
    end
  end
  
  describe "on creation" do
    before do
      @reader = Reader.create :name => "Test Reader", :email => 'test@spanner.org', :nickname => 'test', :password => 'passw0rd', :password_confirmation => 'passw0rd'
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
      reader = Reader.for_user(users(:existing))
      reader.should == readers(:user)
      reader.is_user?.should be_true
      reader.is_admin?.should be_false
    end

    it "should create a matching reader if necessary" do
      user = users(:admin)
      reader = Reader.for_user(user)
      [:name, :email, :created_at, :notes].each do |att|
        reader.send(att).should == user.send(att)
      end
      reader.crypted_password.should == user.password
      ReaderSession.new(:email => user.email, :password => 'password').should be_valid
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
      reader.user.name.should == "Cardinal Fang"
    end
    
    it "should update the user's credentials" do
      reader = readers(:user)
      reader.password = reader.password_confirmation = 'bl0tto'
      reader.save!
      reader.user.authenticated?('bl0tto').should be_true
    end
  end
  
  describe "on activation" do
    before do
      @reader = Reader.create :name => "Test Reader", :email => 'test@spanner.org', :nickname => 'another_nickname', :password => 'passw0rd', :password_confirmation => 'passw0rd', :trusted => 1
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
      @reader = Reader.create :name => "Test Reader", :email => 'test@spanner.org', :nickname => 'test', :password => 'h00haa', :password_confirmation => 'h00haa'
      @reader.activate!
    end
    
    it 'should authenticate' do
      ReaderSession.new(:email => 'test@spanner.org', :password => 'h00haa').should be_valid
    end
  
    it 'should not authenticate with bad password' do
      ReaderSession.new(:email => 'test@spanner.org', :password => 'corcovado').should_not be_valid
    end
  
    it 'should not authenticate if it does not exist' do
      ReaderSession.new(:email => 'loch ness monster', :password => 'blotto').should_not be_valid
    end
  end
end
