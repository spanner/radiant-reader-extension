require File.dirname(__FILE__) + '/../spec_helper'

describe GroupsController do
  dataset :readers
  
  before do
    controller.stub!(:request).and_return(request)
    Page.current_site = sites(:test) if defined? Site
    Radiant::Config['reader.allow_registration?'] = true
  end
    
  describe "listing groups" do
    it "should respond to csv requests"
    it "should respond to vcard requests"
  end

end
