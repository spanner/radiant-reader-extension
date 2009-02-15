require File.dirname(__FILE__) + '/../spec_helper'
ActionMailer::Base.delivery_method = :test  
ActionMailer::Base.perform_deliveries = true  
ActionMailer::Base.deliveries = []
Radiant::Config['readers.default_mail_from_address'] = "test@example.com"
Radiant::Config['readers.default_mail_from_name'] = "test"
Radiant::Config['site.title'] = 'Test Site'
Radiant::Config['site.url'] = 'www.example.com'
Radiant::Config['readers.layout'] = 'Main'

describe Reader do
  dataset :readers
  dataset :reader_layouts
  
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
  
  it 'should await activation after creation' do
    @reader.save!
    @reader.activation_code.should_not be_nil
    @reader.activated_at.should be_nil
    @reader.activated?.should be_false
  end

  it 'should send out an activation email' do
    @reader.save!
    message = ActionMailer::Base.deliveries.last
    message.should_not be_nil
    message.subject.should =~ /activate/
    message.body.should =~ /#{@reader.name}/
    message.body.should =~ /#{@reader.login}/
    message.body.should =~ /#{@reader.current_password}/
  end
  
  it 'should not activate itself without confirmation' do
    @reader.save!
    @reader.activate!('nonsense').should be_false
  end

  it 'should activate itself with confirmation' do
    @reader.save!
    @reader.activate!(@reader.activation_code).should be_true
    @reader.activated?.should be_true
    @reader.activated_at.should_not be_nil
  end
  
  it 'should authenticate after activation' do
    @reader.save!
    @reader.activate!(@reader.activation_code).should be_true
    reader = Reader.authenticate('test', 'password')
    reader.should == @reader
  end
  
  it 'should not authenticate with bad password' do
    Reader.authenticate('test', 'wrong password').should be_nil
  end
  
  it 'should not authenticate if it does not exist' do
    Reader.authenticate('loch ness monster', 'password').should be_nil
  end
  
  it 'should set an activation code when a new password is requested' do
    @reader.save!
    @reader.activate!(@reader.activation_code)
    @reader.activation_code.should be_nil
    @reader.repassword
    @reader.provisional_password.should_not be_nil
    @reader.activation_code.should_not be_nil
  end
  
  it 'should send out a confirmation email when a new password is requested' do
    @reader.save!
    @reader.activate!(@reader.activation_code)
    @reader.repassword
    message = ActionMailer::Base.deliveries.last
    message.should_not be_nil
    message.subject.should == "Reset your password"
    message.body.should =~ /#{@reader.name}/
    message.body.should =~ /#{@reader.login}/
    message.body.should =~ /#{@reader.provisional_password}/
  end
  
  it 'should not change the password without confirmation' do
    @reader.save!
    @reader.activate!(@reader.activation_code)
    @reader.repassword
    @reader.confirm_password('nonsense').should be_false
    @reader.password.should == @reader.sha1('password')
  end
  
  it 'should change the password with confirmation' do
    @reader.save!
    @reader.activate!(@reader.activation_code)
    @reader.repassword
    pw = @reader.provisional_password
    @reader.confirm_password(@reader.activation_code).should be_true
    @reader.password.should == @reader.sha1(pw)
  end
  
  it 'should default to trusted status' do
    @reader.trusted.should == true
  end
  
  it 'should be puttable in the doghouse' do
    @reader.trusted = false
    @reader.trusted.should == false
  end
    
  if defined? MultiSiteExtension
    describe "since multi_site is installed" do
      it "should belong to a site" do
        Reader.reflect_on_association(:site).should_not be_nil
      end
    end
  else
    describe "since multi_site is not installed" do
      it "should not belong to a site" do
        Reader.reflect_on_association(:site).should be_nil
      end
    end
  end
  
end
