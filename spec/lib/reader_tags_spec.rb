require File.dirname(__FILE__) + '/../spec_helper'

describe "Reader Tags" do
  dataset :readers

  let(:person){ readers(:normal) }
  let(:another){ readers(:another) }
  let(:page){ pages(:first) }
  
  describe "r:readers tags" do
    subject { page }
    it { should render(%{<r:readers:each><r:reader:name /></r:readers:each>}).as(Reader.all.map(&:name).join('')) }
  end

  describe "r:reader tags" do 
    describe "on a ReaderPage" do
      before do
        @page = pages(:people)
        @page.stub!(:reader).and_return(person)
      end
      subject { @page }
      it { should render(%{<r:reader:name />}).as(person.name) }
      it { should render(%{<r:if_reader>hello</r:if_reader>}).as('hello') }
      it { should render(%{<r:unless_reader>hello</r:unless_reader>}).as('') }
      [:name, :forename, :email, :description, :login].each { |field| it { should render(%{<r:reader:#{field} id="#{person.id}" />}).as(person.send(field)) } }
    end

    describe "on an uncached page" do
      before do
        @uncached_page = pages(:another)
        @uncached_page.stub!(:cache?).and_return(false)
        Reader.stub!(:current).and_return(readers(:another))
      end
      subject { @uncached_page }
      it { should render(%{<r:reader:name />}).as(another.name) }
      it { should_not render(%{<r:reader:welcome />}).as('') }
    end

    describe "on a cached page" do
      subject { page }
      it { should render(%{<r:reader:name />}).as('') }
      it { should render(%{<r:reader:welcome />}).as('') }
      it { should render(%{<r:reader_welcome />}).as(%{<div class="remote_controls"></div>}) }
      [:name, :forename, :email, :description, :login].each { |field| it { should render(%{<r:reader id="#{another.id}"><r:#{field} /></r:reader>}).as(another.send(field)) } }
    end
  end

  describe "utility tags" do 
    subject { page }
    it { should render(%{<r:truncated chars="50">All happy families are alike; each unhappy family is unhappy in its own way.</r:truncated>}).as(' All happy families are alike; each unhapp&hellip;') }
    it { should render(%{<r:truncated words="5" omission="">All happy families are alike; each unhappy family is unhappy in its own way.</r:truncated>}).as('All happy families are alike;') }
    it { should render(%{<r:truncated words="5" allow_html="true" omission=" (tbc)">All <em>happy families</em> are alike; each unhappy family is unhappy in its own way.</r:truncated>}).as('All <em>happy families</em> are alike; (tbc)') }
  end

end