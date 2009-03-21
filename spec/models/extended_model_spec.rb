require File.dirname(__FILE__) + '/../spec_helper'

describe "extended model" do
  dataset :users
  
  it "should have useful named_scopes" do
    lambda { Snippet.since(1.week.ago) }.should_not raise_error
    lambda { Snippet.by_user(users(:existing)) }.should_not raise_error
  end
end
