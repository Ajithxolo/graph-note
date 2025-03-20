require 'rails_helper'

RSpec.describe 'GraphQL searchNotes query', type: :request do
  let!(:note1) { create(:note, title: "GraphQL Guide", body: "Elasticsearch integration in Rails GraphQL.", sentiment_label: "neutral", sentiment_score: 0.0) }
  let!(:note2) { create(:note, title: "Rails Testing", body: "TDD with RSpec and Capybara.", sentiment_label: "neutral", sentiment_score: 0.0) }
  let!(:note3) { create(:note, title: "Elastic Power", body: "Full-text search using Elasticsearch, I'm very happy", sentiment_label: "positive", sentiment_score: 1.0) }

  let(:query) do
    <<-GRAPHQL
      {
        searchNotes(keyword: "GraphQL") {
          id
          title
          body
          sentimentScore
          sentimentLabel
        }
      }
    GRAPHQL
  end

  before do
    allow(Note).to receive(:search_by_keyword).and_return([note1])
  end

  context 'when searching with a valid keyword' do
    it 'returns notes matching the search keyword' do
      post '/graphql', params: { query: query }
      json = JSON.parse(response.body)

      expect(json['data']['searchNotes']).to be_an(Array)
      expect(json['data']['searchNotes'].size).to be >= 1
      expect(json['data']['searchNotes'].first['title']).to include("GraphQL")
    end
  end
end
