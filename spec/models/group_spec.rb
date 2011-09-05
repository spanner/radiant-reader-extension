require File.dirname(__FILE__) + '/../spec_helper'

describe Group do
  dataset :readers

  it "should have a homepage association" do
    Group.reflect_on_association(:homepage).should_not be_nil
    group = groups(:homed)
    group.homepage.should be_a(Page)
    group.homepage = pages(:child)
    group.homepage.should == pages(:child)
  end

  it "should have a group of readers" do
    group = groups(:normal)
    group.respond_to?(:readers).should be_true
    group.readers.any?.should be_true
    group.readers.size.should == 2
  end

  it "should have a group of pages" do
    group = groups(:homed)
    group.respond_to?(:pages).should be_true
    group.pages.any?.should be_true
    group.pages.size.should == 2
  end
  
  describe "on validation" do
    before do
      @group = Group.new :name => "Unique Test Group"
      @group.should be_valid
    end
    
    it "should require a name" do
      @group.name = nil
      @group.should_not be_valid
      @group.errors.on(:name).should_not be_empty
    end

    it "should require a unique name" do
      duplicate = Group.new :name => "Normal"
      duplicate.should_not be_valid
      duplicate.errors.on(:name).should_not be_empty
    end
    
    it "should give itself a slug if none is present" do
      g = Group.new(:name => 'testy group')
      g.valid?.should be_true
      g.slug.should == 'testy-group'
    end
  end
  
  describe "in a hierarchy" do
    it "should have parent and children relations" do
      group = groups(:subgroup)
      group.respond_to?(:parent).should be_true
      group.respond_to?(:children).should be_true
      group.children.should =~ [groups(:subsubgroup), groups(:anothersubsubgroup)]
      group.parent.should == groups(:supergroup)
    end
    
    it "should have descendants and ancestors" do
      groups(:subsubgroup).path.should == [groups(:supergroup), groups(:subgroup), groups(:subsubgroup)]
      groups(:subsubgroup).root.should == groups(:supergroup)
      groups(:supergroup).subtree.should =~ [groups(:supergroup), groups(:subgroup), groups(:subsubgroup), groups(:anothersubsubgroup)]
    end

    it "should have a root group" do
      [:supergroup, :subgroup, :subsubgroup].each do |g|
        groups(g).root.should == groups(:supergroup)
      end
    end

    it "should inherit memberships from descendants" do
      groups(:supergroup).members.should =~ [readers(:normal), readers(:another)]
    end
    
    it "should not inherit memberships from ancestors" do
      groups(:subsubgroup).members.should be_empty
    end
    
    it "should inherit permissions from ancestors" do
      groups(:subsubgroup).pages.should =~ [pages(:child), pages(:child_2)]
    end

    it "should not inherit permissions from descendants" do
      groups(:supergroup).pages.should be_empty
    end
  end
  
  describe "directory visibility" do
    describe "when directory is grouped" do
      before do
        Radiant.config['reader.directory_visibility'] = 'grouped'
      end
      
      it "should be visible to members" do
        groups(:subgroup).visible_to?(readers(:normal)).should be_true
      end
      
      it "should be visible to members of ancestor groups" do
        groups(:supergroup).visible_to?(readers(:normal)).should be_true
      end
      
      it "should be visible to members of descendant groups" do
        groups(:subsubgroup).visible_to?(readers(:normal)).should be_true
      end
      
      it "should not be visible to members of groups outside the family" do
        groups(:subgroup).visible_to?(readers(:inactive)).should be_false
      end
      
      it "should not be visible to readers without groups" do
        groups(:subgroup).visible_to?(readers(:ungrouped)).should be_false
      end
    end

  end
end
