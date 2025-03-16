require 'rails_helper'
Result = Struct.new(:success?, :note, :errors, :error)

RSpec.describe 'GraphQL Note Mutations', type: :request do
  let(:create_note_mutation) do
    <<-GRAPHQL
      mutation CreateNote($title: String!, $body: String!) {
        createNote(input: { title: $title, body: $body }) {
          note {
            id
            title
            body
            sentimentScore
            sentimentLabel
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
            sentimentScore
            sentimentLabel
          }
          errors
        }
      }
    GRAPHQL
  end

  let(:delete_note_mutation) do
    <<-GRAPHQL
      mutation DeleteNote($id: ID!) {
        deleteNote(input: { id: $id}) {
          success
          errors
        }
      }
    GRAPHQL
  end

  describe '#CreateNote' do
    let(:note) { create(:note, title: 'New Note', body: 'This is a positive note.', sentiment_score: 1.0, sentiment_label: 'positive') }

    context 'when valid parameters are provided' do
      let(:parameters) { { title: "New Note", body: "This is a positive note." } }

      before do
        allow(NoteService).to receive(:create_note).and_return(Result.new(true, note, []))
      end

      it 'creates a note successfully' do
        post '/graphql', params: { query: create_note_mutation, variables: parameters }
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        data = json['data']['createNote']
        created_note = data['note']
        errors = data['errors']
        expect(created_note['title']).to eq(parameters[:title])
        expect(created_note['body']).to eq(parameters[:body])
        expect(created_note['sentimentScore']).to eq(1.0)
        expect(created_note['sentimentLabel']).to eq('positive')
        expect(errors).to be_empty
      end
    end

    context 'when invalid parameters are provided' do
      let(:invalid_parameters) { { title: "", body: "" } }

      before do
        allow(NoteService).to receive(:create_note).and_return(Result.new(false, nil, [ "title must be present", "body must be present" ]))
      end

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
  end

  describe '#UpdateNote' do
    context 'when valid update parameters are provided' do
      let(:existing_note) { create(:note, title: 'Test Note', body: 'This is a positive test.', sentiment_score: 1.0, sentiment_label: 'positive') }
      let(:updated_note) do
        existing_note.dup.tap do |n|
          n.id = existing_note.id
          n.title = 'Updated Title'
          n.body = 'Updated positive test'
        end
      end

      let(:valid_update_parameters) { { id: existing_note.id, title: 'Updated Title', body: 'Updated positive test' } }

      before do
        allow(NoteService).to receive(:update_note).and_return(Result.new(true, updated_note, []))
      end

      it 'updates the note successfully' do
        post '/graphql', params: { query: update_note_mutation, variables: valid_update_parameters }
        json_response = JSON.parse(response.body)
        updated_note = json_response["data"]["updateNote"]["note"]
        expect(updated_note["title"]).to eq("Updated Title")
        expect(updated_note["body"]).to eq("Updated positive test")
        expect(updated_note["sentimentScore"]).to eq(1.0)
        expect(updated_note["sentimentLabel"]).to eq('positive')
        expect(json_response["data"]["updateNote"]["errors"]).to be_empty
      end
    end

    context 'when existing note was not found' do
      let(:valid_update_parameters) { { id: 122, title: "Updated Title", body: "Updated Body" } }

      it 'return error not found' do
        post '/graphql', params: { query: update_note_mutation, variables: valid_update_parameters }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        update_note_response = json_response["data"]["updateNote"]
        errors = update_note_response['errors']

        expect(errors).not_to be_empty
        expect(errors).to include('Note not found')
        expect(update_note_response["note"]).to be_nil
      end
    end
  end

  describe '#delete_note' do
    context 'when valid id is provided' do
      before do
        allow(NoteService)
          .to receive(:delete_note)
          .and_return({ success: true, errors: [] })
      end
      let(:existing_note) { create(:note, title: "Test Note", body: "This is a test.") }
      it 'deletes a note successfully' do
        note_id = { id: existing_note.id }

        post '/graphql', params: { query: delete_note_mutation, variables: note_id }
        json = JSON.parse(response.body)

        expect(json["data"]["deleteNote"]["success"]).to be true
        expect(json["data"]["deleteNote"]["errors"]).to be_empty
      end
    end

    context 'when invalid id is provided' do
      before do
        allow(NoteService)
          .to receive(:delete_note)
          .and_return({ success: false, errors: [ "note not found" ] })
      end
      it 'return error with success as false' do
        invalid_note_id = { id: 000 }

        post '/graphql', params: { query: delete_note_mutation, variables: invalid_note_id }
        json = JSON.parse(response.body)

        expect(json["data"]["deleteNote"]["success"]).to be false
        expect(json["data"]["deleteNote"]["errors"]).not_to be_empty
      end
    end
  end
end
