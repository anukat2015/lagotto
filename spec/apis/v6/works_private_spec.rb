require "rails_helper"

describe "/api/v6/works", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/vnd.lagotto+json; version=6",
      "Authorization" => "Token token=#{user.api_key}" }
  end

  context "private source" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/works?ids=#{work.doi_escaped}" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        expect(item["metrics"]["citeulike"]).to eq(work.retrieval_statuses.first.total)
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/works?ids=#{work.doi_escaped}" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        expect(item["metrics"]["citeulike"]).to eq(work.retrieval_statuses.first.total)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/works?ids=#{work.doi_escaped}" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        expect(item["metrics"]["citeulike"]).to be_nil
      end
    end

    context "without API key" do
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/works?ids=#{work.doi_escaped}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/vnd.lagotto+json; version=6'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        expect(item["metrics"]["citeulike"]).to be_nil
      end
    end
  end
end
