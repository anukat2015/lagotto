require 'rails_helper'

describe Status, type: :model, vcr: true do
  subject { FactoryGirl.create(:status) }

  it "works_count" do
    FactoryGirl.create_list(:work_published_today, 5)
    expect(subject.works_count).to eq(10)
  end

  it "works_new_count" do
    FactoryGirl.create_list(:work_published_today, 5)
    expect(subject.works_new_count).to eq(10)
  end

  it "events_count" do
    FactoryGirl.create_list(:work_published_today, 5)
    expect(subject.events_count).to eq(250)
  end

  it "alerts_count" do
    FactoryGirl.create_list(:alert, 5)
    expect(subject.alerts_count).to eq(5)
  end

  it "responses_count" do
    FactoryGirl.create_list(:api_response, 5, created_at: Time.zone.now - 1.hour)
    expect(subject.responses_count).to eq(5)
  end

  it "requests_count" do
    FactoryGirl.create_list(:api_request, 5, created_at: Time.zone.now - 1.hour)
    expect(subject.requests_count).to eq(5)
  end

  it "requests_average" do
    FactoryGirl.create_list(:api_request, 5, created_at: Time.zone.now - 1.hour)
    expect(subject.requests_average).to eq(800)
  end

  it "current_version" do
    expect(subject.current_version).to eq("3.13")
  end

  context "services" do
    it "redis" do
      expect(subject.redis).to eq("OK")
    end

    it "sidekiq" do
      expect(subject.sidekiq).to eq("failed")
    end

    it "postfix" do
      expect(subject.postfix).to eq("OK")
    end

    it "services_ok?" do
      expect(subject.services_ok?).to be false
    end
  end
end
