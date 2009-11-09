require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  dataset :messages
  
  before do

  end
  
  describe "on validation" do
    before do
      @message = messages(:normal)
      @message.should be_valid
    end
    
    it "should require a subject" do
      @message.subject = nil
      @message.should_not be_valid
      @message.errors.on(:subject).should_not be_empty
    end
    
    it "should require a body" do
      @message.body = ""
      @message.should_not be_valid
      @message.errors.on(:body).should_not be_empty
    end
  end
  
  describe "with a filter" do
    it "should format itself" do
      messages(:filtered).body.should == "this is a *filtered* message"
      messages(:filtered).filtered_body.should == "<p>this is a <strong>filtered</strong> message</p>"
    end
  end
  
  describe "on preview" do
    before do
      @preview = messages(:taggy).preview
    end

    it "should render a fake sending" do
      @preview.should be_kind_of(TMail::Mail)
      @preview.from.should == [messages(:taggy).created_by.email]
      @preview.subject.should == messages(:taggy).subject
      @preview.body.should =~ /From #{messages(:taggy).created_by.name}/
    end
  end
  
  describe "with a reader association" do
    before do
      @message = messages(:normal)
      @message.readers << readers(:normal)
    end
    
    describe "but unsent" do
      it "should know to whom it can belong" do
        @message.possible_readers.count.should == Reader.active.count
      end

      it "should know to whom it does belong" do
        @message.readers.include?(readers(:normal)).should be_true
      end
    
      it "should report itself unsent to anyone" do
        @message.delivered?.should be_false
      end
    
      it "should report itself not sent to one of its readers" do
        @message.delivered_to?(readers(:normal)).should be_false
      end

      it "should report itself not sent to an unrelated reader" do
        @message.delivered_to?(readers(:visible)).should be_false
      end
    end

    describe "already sent to one reader" do
      before do
        seem_to_send(messages(:normal), readers(:normal))
        @message.readers << readers(:visible)
      end
      
      it "should report itself delivered" do
        @message.delivered?.should be_true
      end
    
      it "should know to whom it has been sent" do
        @message.recipients.should == [readers(:normal)]
      end
    
      it "should know to whom it has yet to be sent" do
        @message.undelivered_readers.should == Reader.active - @message.recipients
      end
    
      it "should report itself delivered to that reader" do
        @message.delivered_to?(readers(:normal)).should be_true
      end

      it "should report itself not yet sent to other readers" do
        @message.readers.include?(readers(:visible)).should be_true
        @message.delivered_to?(readers(:visible)).should be_false
      end

    end
    
    
  end
  
end
