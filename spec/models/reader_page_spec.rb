require File.dirname(__FILE__) + '/../spec_helper'

describe ReaderPage do
  dataset :readers
  activate_authlogic
  
  let(:page) { Page.find_by_path('/directory') }
  let(:page_with_group) { Page.find_by_path('/directory/normal') }
  let(:page_with_reader) { Page.find_by_path("/directory/#{reader_id(:normal)}") }
  let(:page_with_reader_and_group) { Page.find_by_path("/directory/special/#{reader_id(:another)}") }
  
  it "should be a Page" do
    page.is_a?(Page).should be_true
  end
  
  describe "reading parameters" do
    before do
      Radiant.config['readers.public?'] = true
    end

    it "should interrupt the find_by_path cascade" do
      page.should == pages(:people)
      page.should == pages(:people)
      page_with_reader_and_group.is_a?(ReaderPage).should be_true
      page.reader.should be_nil
      page.group.should be_nil
    end

    it "should read a group slug parameter" do
      page_with_group.group.should == groups(:normal)
      page_with_reader_and_group.group.should == groups(:special)
      page_with_reader.group.should be_nil
    end

    it "should read a reader id parameter" do
      page_with_reader.reader.should == readers(:normal)
      page_with_reader_and_group.reader.should == readers(:another)
      page_with_group.reader.should be_nil
    end
    
    it "should take exception to mismatched reader and group" do
      lambda { Page.find_by_path("/directory/special/#{reader_id(:ungrouped)}") }.should raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should list readers and groups" do
      page.readers.should =~ Reader.all
      page.groups.should =~ Group.all
    end
  end
  
  describe "when the readership is private" do
    before do
      Radiant.config['readers.public?'] = false
    end
    
    describe "and no reader is logged in" do
      before do
        logout_reader
        Reader.current = nil
      end
      
      it "should deny access completely" do
        lambda { Page.find_by_path("/directory") }.should raise_error(ReaderError::AccessDenied)
        lambda { Page.find_by_path("/directory/normal") }.should raise_error(ReaderError::AccessDenied)
      end
    end
    
    describe "and a reader is logged in" do
      before do
        Reader.current = login_as_reader(readers(:normal))
      end
      
      it "should allow access to the reader list" do
        lambda { Page.find_by_path("/directory") }.should_not raise_error
      end

      it "should allow access to a group" do
        lambda { Page.find_by_path("/directory/normal").group.should == groups(:normal) }.should_not raise_error
      end

      it "should allow access to a reader" do
        lambda { Page.find_by_path("/directory/#{reader_id(:normal)}").reader.should == readers(:normal) }.should_not raise_error
      end

      describe "but confined to his groups" do
        before do
          Radiant.config['readers.confine_to_groups?'] = true
          Reader.current = login_as_reader(readers(:normal))
        end

        it "should allow access only to readers with group overlap" do
          lambda { Page.find_by_path("/directory/#{reader_id(:inactive)}").reader.should == readers(:inactive) }.should_not raise_error
          lambda { Page.find_by_path("/directory/#{reader_id(:another)}") }.should raise_error
        end

        it "should allow access only to groups to which the reader belongs" do
          lambda { Page.find_by_path("/directory/normal") }.should_not raise_error
          lambda { Page.find_by_path("/directory/special") }.should raise_error(ReaderError::AccessDenied)
          Page.find_by_path("/directory").groups.should =~ [groups(:normal), groups(:homed)]
          Page.find_by_path("/directory").readers.should =~ (groups(:normal).readers + groups(:homed).readers).uniq
        end
      end

    end
  end
end
