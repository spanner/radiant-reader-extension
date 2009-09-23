require File.dirname(__FILE__) + '/../spec_helper'

describe ReaderNotifier do
  dataset :readers, :reader_layouts, :messages
  
  before do
    Radiant::Config['email.layout'] = 'email'
  end
    
  it "should have a radiant layout attribute" do
    ReaderNotifier.read_inheritable_attribute('radiant_mailer_layout_name').should_not be_nil
    ReaderNotifier.read_inheritable_attribute('radiant_mailer_layout_name').should be_kind_of(Proc)
  end

  it "should render a supplied message" do
    message = ReaderNotifier.create_message(readers(:normal), messages(:normal))
    message.to.should == [readers(:normal).email]
    message.from.should == [users(:existing).email]
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
    message.body.should =~ /From #{users(:existing).name}/
  end
  
end
