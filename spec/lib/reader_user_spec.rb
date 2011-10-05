require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  dataset :readers
  # activate_authlogic
  
  let(:user) { users(:existing) }
  let(:reader) { readers(:user) }
  
  it "should have an associated reader" do
    user.reader.should == reader
    reader.user.should == user
  end
  
  describe "on update" do
    it "should update the attributes of an associated reader" do
      user.name = "Cardinal Fang"
      user.save!
      user.reader.name.should == "Cardinal Fang"
      Reader.find_by_name("Cardinal Fang").should == readers(:user)
    end
    
    it "should update the associated reader's credentials" do
      user.password = user.password_confirmation = 'bl0tto'
      user.save!
      user.authenticated?('bl0tto').should be_true
      user.reader.valid_password?('bl0tto').should be_true
      # ReaderSession.new(:login => reader.login, :password => 'bl0tto').should be_valid
    end
  end
end
