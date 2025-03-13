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

  let(:update_note_mutation) do
    <<-GRAPHQL
      mutation UpdateNote($id: ID!, $title: String!, $body: String!) {
        updateNote(input: { id: $id, title: $title, body: $body }) {
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

  context 'when invalid parameters are provided' do
    let(:invalid_parameters) { { title: "", body: "" } }

    it 'returns errors and does not create a note' do
      post '/graphql', params: { query: create_note_mutation, variables: invalid_parameters }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      data = json['data']['createNote']
      errors = data['errors']

      expect(errors).not_to be_empty
      expect(data['note']).to be_nil
    end
  end

  context 'when valid update parameters are provided' do
    let(:existing_note) { create(:note, title: "Test Note", body: "This is a test.") }
    let(:valid_update_parameters) { { id: existing_note.id, title: "Updated Title", body: "Updated Body" } }

    it 'updates the note successfully' do
      post '/graphql', params: { query: update_note_mutation, variables: valid_update_parameters }
      json_response = JSON.parse(response.body)
      updated_note = json_response["data"]["updateNote"]["note"]

      expect(updated_note["title"]).to eq("Updated Title")
      expect(updated_note["body"]).to eq("Updated Body")
      expect(json_response["data"]["updateNote"]["errors"]).to be_empty
    end
  end
end
