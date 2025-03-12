require 'rails_helper'

RSpec.describe 'GraphQL Note Mutations', type: :request do
  let(:create_note_mutation) do
    <<-GRAPHQL
      mutation CreateNote($title: String!, $body: String!) {
        createNote(input: { title: $title, body: $body }) {
          note {
            id
            title
            body
          }
          errors
        }
      }
    GRAPHQL
  end
  context 'when valid parameters are provided' do
    let(:parameters) { { title: "New Note", body: "This is a new note." } }

    it 'creates a note successfully' do
      post '/graphql', params: { query: create_note_mutation, variables: parameters }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      data = json['data']['createNote']
      created_note = data['note']
      errors = data['errors']

      expect(created_note['title']).to eq("New Note")
      expect(created_note['body']).to eq("This is a new note.")
      expect(errors).to be_empty
    end
  end
end
