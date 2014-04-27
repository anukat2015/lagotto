require 'spec_helper'

describe F1000 do
  subject { FactoryGirl.create(:f1000) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    subject.parse_data(article).should eq(events: [], event_count: nil)
  end

  context "save f1000 data" do
    it "should fetch and save f1000 data" do
      # stub = stub_request(:get, subject.get_feed_url).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'f1000.xml'), :status => 200)
      # subject.get_feed.should be_true
      # file = "#{Rails.root}/data/#{subject.filename}.xml"
      # File.exist?(file).should be_true
      # stub.should have_been_requested
      # Alert.count.should == 0
    end
  end

  context "parse f1000 data" do
    before(:each) do
      subject.put_alm_data(subject.url)
    end

    after(:each) do
      subject.delete_alm_data(subject.url)
    end

    it "should parse f1000 data" do
      subject.parse_feed.should be_true
      Alert.count.should == 0
    end
  end

  context "use the f1000 internal database" do
    before(:each) do
      subject.put_alm_data(subject.url)
    end

    after(:each) do
      subject.delete_alm_data(subject.url)
    end

    it "should report if there are no events and event_count returned by f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0044294")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'f1000_nil.json'), :status => 200)
      subject.parse_data(article).should eq(:events=>[], :event_count=>0, :events_url=>nil, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pbio.1001420")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => File.read(fixture_path + 'f1000.json'), :status => 200)
      response = subject.parse_data(article)
      response[:event_count].should == 2
      response[:events_url].should eq("http://f1000.com/prime/718293874")

      event = response[:events].last
      event[:event]['classifications'].should eq(["confirmation", "good_for_teaching"])
      stub.should have_been_requested
    end

    it "should catch errors with f1000" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      subject.parse_data(article, options = { :source_id => subject.id }).should eq(:events=>[], :event_count=>0)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end
end
