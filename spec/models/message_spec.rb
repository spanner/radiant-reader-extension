require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  dataset :readers
  
  before do

  end
  
  it "should have a groups association" do
    Message.reflect_on_association(:groups).should_not be_nil
  end
  
  it "should normally list only the ungrouped messages" do
    Message.visible.count.should == 7
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
      @preview.from.should == ["admin@www.example.com"]
      @preview.subject.should == messages(:taggy).subject
    end
  end
  
  describe "on delivery" do
    before do
      @message = messages(:normal)
    end
    
    describe "previously unsent" do
      it "should know to whom it can belong" do
        @message.possible_readers.count.should == Reader.count
        @message.active_readers.count.should == Reader.active.count
        @message.inactive_readers.count.should == Reader.inactive.count
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
      end
      
      it "should report itself delivered" do
        @message.delivered?.should be_true
      end
    
      it "should know to whom it has been sent" do
        @message.recipients.should == [readers(:normal)]
      end
    
      it "should know to whom it has yet to be sent" do
        @message.undelivered_readers.should =~ Reader.all - @message.recipients
      end
    
      it "should report itself delivered to that reader" do
        @message.delivered_to?(readers(:normal)).should be_true
      end

      it "should report itself not yet sent to other readers" do
        @message.delivered_to?(readers(:visible)).should be_false
      end
    end

    describe "with a group" do
      it "should report itself visible to a reader who is a group member" do
        messages(:grouped).visible_to?(readers(:normal)).should be_true
      end
      it "should report itself invisible to a reader who is not a group member" do
        messages(:grouped).visible_to?(readers(:ungrouped)).should be_false
      end
      it "should list only group members as possible readers" do
        messages(:grouped).possible_readers.include?(readers(:normal)).should be_true
        messages(:grouped).possible_readers.include?(readers(:ungrouped)).should be_false
      end
    end

    describe "without a group" do
      it "should report itself visible to everyone" do
        messages(:normal).visible_to?(readers(:normal)).should be_true
        messages(:normal).visible_to?(readers(:ungrouped)).should be_true
      end

      it "should list all readers as possible readers" do
        messages(:normal).possible_readers.include?(readers(:normal)).should be_true
        messages(:normal).possible_readers.include?(readers(:ungrouped)).should be_true
      end
    end
  end

end
