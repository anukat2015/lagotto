require 'spec_helper'

describe "db:articles:seed" do
  include_context "rake"

  let(:output) { "Seeded 25 articles\n" }

  its(:prerequisites) { should include("environment") }

  it "should run the rake task" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:articles:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:article, 5)
  end

  let(:output) { "Deleted 5 articles, 0 articles remaining\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:alerts:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:alert, 5, :unresolved => false)
  end

  let(:output) { "Deleted 5 resolved alerts, 0 unresolved alerts remaining\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end

describe "db:api_requests:delete" do
  include_context "rake"

  before do
    FactoryGirl.create_list(:api_request, 5)
  end

  let(:output) { "Deleted 0 API requests, 5 API requests remaining\n" }

  it "should run" do
    capture_stdout { subject.invoke }.should eq(output)
  end
end
