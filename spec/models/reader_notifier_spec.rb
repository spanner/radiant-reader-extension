require File.dirname(__FILE__) + '/../spec_helper'

describe ReaderNotifier do
  dataset :readers
  
  before do
    Radiant::Config['email.layout'] = 'email'
  end
    
  it "should have a radiant layout attribute" do
    ReaderNotifier.read_inheritable_attribute(:default_layout).should_not be_nil
  end

  it "should render a supplied message" do
    message = ReaderNotifier.create_message(readers(:normal), messages(:normal))
    message.to.should == [readers(:normal).email]
    message.from.should == ["admin@www.example.com"]
    message.body.should =~ /#{messages(:normal).filtered_body}/
    message.content_type.should == 'text/html'
  end
  
  it "should render messages with layout" do
    message = ReaderNotifier.create_message(readers(:normal), messages(:normal))
    message.body.should =~ /<head>/
  end
  
  it "should render radius tags within a message" do
    message = ReaderNotifier.create_message(readers(:normal), messages(:taggy))
    message.body.should =~ /<title>#{messages(:taggy).subject}<\/title>/
    message.body.should =~ /To #{readers(:normal).name}/
  end
  
end
