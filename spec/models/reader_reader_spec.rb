require File.dirname(__FILE__) + '/../spec_helper'

describe Reader do
  dataset :readers
  
  before do
    @reader = Reader.new :name => "Test Reader", :email => 'test@spanner.org', :login => 'test', :password => 'password', :password_confirmation => 'password', :trusted => 1
    @reader.confirm_password = false
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
    @reader.email = 'bad@punctuation'
    @reader.should_not be_valid
  end
  
  it "should require a unique login" do
    @reader.login = readers(:normal).login
    @reader.should_not be_valid
    @reader.errors.on(:login).should_not be_empty
  end
    
  it 'should confirm the password by default' do
    @reader = Reader.new
    @reader.confirm_password?.should == true
  end
  
  it 'should save password encrypted' do
    @reader.confirm_password = true
    @reader.password_confirmation = @reader.password = 'test_password'
    @reader.save!
    @reader.password.should == @reader.sha1('test_password')
  end
  
  it 'should keep existing password when empty password is supplied' do
    @reader.save!
    @reader.password_confirmation = @reader.password = ''
    @reader.save!
    @reader.password.should == @reader.sha1('password')
  end
  
  it 'should save new password if different' do
    @reader.save!
    @reader.password_confirmation = @reader.password = 'cool beans'
    @reader.save!
    @reader.password.should == @reader.sha1('cool beans')
  end
  
  it "should create a salt when encrypting the password" do
    @reader.salt.should be_nil
    @reader.send(:encrypt_password)
    @reader.salt.should_not be_nil
    @reader.password.should == @reader.sha1('password')
  end
  
  it 'should verify its email address' do

  end
  
  it 'should default to trusted status' do
    @reader.trusted.should == true
  end
  
  it 'should be puttable in the doghouse' do
    @reader.trusted = false
    @reader.trusted.should == false
  end
  
  it 'should authenticate with correct username and password' do
    @reader.save!
    reader = Reader.authenticate('test', 'password')
    reader.should == @reader
  end
  
  it 'should not authenticate with bad password' do
    Reader.authenticate('test', 'bad password').should be_nil
  end
  
  it 'should not authenticate with nonexistent user' do
    Reader.authenticate('loch ness monster', 'password').should be_nil
  end
end
