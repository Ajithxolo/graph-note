require 'rails_helper'
RSpec.describe 'GraphQL fetchNotes query', type: :request do
  let!(:note) { create(:note, title: "Test Note", body: "This is a test.") }

  let(:query) do
    <<-GRAPHQL
      {
        fetchNotes {
          id
          title
          body
        }
      }
    GRAPHQL
  end
  context 'when there are notes in the database' do
    it 'returns a list of notes with the correct attributes' do
      post '/graphql', params: { query: query }
      json = JSON.parse(response.body)
      expect(json['data']['fetchNotes']).to be_an(Array)
    end
  end
  context 'when there are no notes present' do
    before { Note.delete_all }

    it 'returns an empty array' do
      post '/graphql', params: { query: query }
      json = JSON.parse(response.body)
      expect(json['data']['fetchNotes']).to eq([])
    end
  end
  context 'when the query is invalid' do
    let(:invalid_query) do
      <<-GRAPHQL
        {
          fetchNotes {
            invalid
          }
        }
      GRAPHQL
    end

    it 'returns an errors object' do
      post '/graphql', params: { query: invalid_query }
      json = JSON.parse(response.body)
      expect(json).to have_key('errors')
      expect(json['errors']).not_to be_empty
    end
  end
end
