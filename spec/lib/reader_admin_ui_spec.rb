require File.dirname(__FILE__) + "/../spec_helper"

describe "AdminUI extensions for readers" do
  before :each do
    @admin = Radiant::AdminUI.new
    @admin.reader = Radiant::AdminUI.load_default_reader_regions
  end

  it "should be included into Radiant::AdminUI" do
    Radiant::AdminUI.included_modules.should include(ReaderAdminUI)
  end

  it "should define a collection of Region Sets for readers" do
    @admin.should respond_to('reader')
    @admin.should respond_to('readers')
    @admin.send('reader').should_not be_nil
    @admin.send('reader').should be_kind_of(OpenStruct)
  end

  describe "should define default regions" do
    %w{new edit remove index}.each do |action|
      
      describe "for '#{action}'" do
        before do
          @reader = @admin.reader
          @reader.send(action).should_not be_nil
        end
              
        it "as a RegionSet" do
          @reader.send(action).should be_kind_of(Radiant::AdminUI::RegionSet)
        end
      end
    end
  end
end
