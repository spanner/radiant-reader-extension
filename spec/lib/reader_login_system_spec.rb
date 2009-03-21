require File.dirname(__FILE__) + "/../spec_helper"

class StubController < ActionController::Base
  include LoginSystem
  include ReaderLoginSystem
  
  def rescue_action(e) raise e end
  
  def method_missing(method, *args, &block)
    if (args.size == 0) and not block_given?
     # render :text => 'just a test' unless @performed_render || @performed_redirect
    else
      super
    end
  end
end

describe 'Reader Login System:', :type => :controller do
  controller_name "stub"
  dataset :users
  dataset :readers
  
  before do
    map = ActionController::Routing::RouteSet::Mapper.new(ActionController::Routing::Routes)
    map.connect ':controller/:action/:id'
    ActionController::Routing::Routes.named_routes.install
    controller.stub!(:request).and_return(request)
    controller.set_current_site if defined? Site
  end

  after do
    ActionController::Routing::Routes.reload
  end
  
  describe "authenticating" do
    before do
      Time.zone = 'UTC'
      Radiant::Config.stub!(:[]).with('session_timeout').and_return(2.weeks)
    end

    it "should not login reader if no cookie found" do
      controller.should_not_receive(:current_reader=)
      get :index
    end

    describe "with reader_session_token" do
      before do
        @cookies = { :reader_session_token => 12345 }
        @reader = readers(:normal)
        controller.stub!(:cookies).and_return(@cookies)
        Reader.should_receive(:find_by_session_token).and_return(@reader)
      end

      after do
        controller.send :login_from_cookie
      end

      it "should log in reader" do
        controller.should_receive(:current_reader=).with(@reader).and_return {
          controller.stub!(:current_reader).and_return(@reader)
        }
      end

      it "should remember reader" do
        @reader.should_receive(:remember_me)
      end

      it "should update cookie" do
        @cookies.should_receive(:[]=) do |name,content|
          name.should eql(:reader_session_token)
          content[:value].should eql(@reader.session_token)
          content[:expires].should be_close((Time.zone.now + 2.weeks).utc, 1.minute) # sometimes specs are slow
        end
      end
    end

    describe "with session_token" do
      before do
        @user = users(:existing)
        @reader = readers(:user)
        @cookies = { :session_token => 12345 }
        controller.stub!(:cookies).and_return(@cookies)
        User.should_receive(:find_by_session_token).and_return(@user)
      end

      after do
        controller.send :login_from_cookie
      end

      it "should log in user" do
        controller.should_receive(:current_user=).with(@user).and_return {
          controller.stub!(:current_user).and_return(@user)
        }
      end
    end
    
    describe "with both session tokens" do
      before do
        @user = users(:existing)
        @cookies = { :session_token => 12345, :reader_session_token => 12345 }
        @reader = readers(:normal)
        controller.stub!(:cookies).and_return(@cookies)
        Reader.should_receive(:find_by_session_token).and_return(@reader)
        User.should_receive(:find_by_session_token).and_return(@user)
      end

      after do
        controller.send :login_from_cookie
      end

      it "should log in both user and reader" do
        controller.should_receive(:current_reader=).with(@reader).and_return {
          controller.stub!(:current_reader).and_return(@reader)
        }
        controller.should_receive(:current_user=).with(@user).and_return {
          controller.stub!(:current_user).and_return(@user)
        }
      end
    end
  end 
  
  describe '.authenticate' do
    
  end
  
  
  
  
  
  
end