require 'rails_helper'

RSpec.describe NoteService, type: :service do
  describe '#create_note' do
    subject(:result) { described_class.create_note(attributes) }

    context 'when valid attributes are passed' do
      let(:attributes) { { title: 'Test Note', body: 'This is a positive note.' } }
      let(:sentiment_result) { { sentiment_score: 1.0, sentiment_label: 'positive' } }

      before do
        expect_any_instance_of(SentimentAnalysisService)
          .to receive(:analyze)
          .with(attributes[:body])
          .and_return(sentiment_result)
      end

      it 'creates a note with sentiment analysis results' do
        aggregate_failures do
          expect(result.success?).to be true
          note = result.note
          expect(note).to be_persisted
          expect(note.title).to eq('Test Note')
          expect(note.body).to eq('This is a positive note.')
          expect(note.sentiment_score).to eq(1.0)
          expect(note.sentiment_label).to eq('positive')
        end
      end
    end
  end

  describe '#update_note' do
    let!(:note) { create(:note, title: 'Original Title', body: 'Original body', sentiment_score: 0.0, sentiment_label: 'neutral') }

    context 'when the body is changed' do
      let(:attributes) { { id: note.id, title: 'Updated Title', body: 'This is an updated positive note.' } }
      let(:sentiment_result) { { sentiment_score: 1.0, sentiment_label: 'positive' } }

      before do
        expect_any_instance_of(SentimentAnalysisService)
          .to receive(:analyze)
          .with(attributes[:body])
          .and_return(sentiment_result)
      end

      it 'updates the note and recalculates sentiment' do
        result = described_class.update_note(attributes)
        aggregate_failures do
          expect(result.success?).to be true
          updated_note = result.note
          expect(updated_note.title).to eq('Updated Title')
          expect(updated_note.body).to eq('This is an updated positive note.')
          expect(updated_note.sentiment_score).to eq(1.0)
          expect(updated_note.sentiment_label).to eq('positive')
        end
      end
    end

    context 'when the body remains unchanged' do
      let(:attributes) { { id: note.id, title: 'Updated Title', body: note.body } }

      it 'updates the note without re-calling sentiment analysis' do
        expect_any_instance_of(SentimentAnalysisService).not_to receive(:analyze)
        result = described_class.update_note(attributes)
        aggregate_failures do
          expect(result.success?).to be true
          updated_note = result.note
          expect(updated_note.title).to eq('Updated Title')
          expect(updated_note.body).to eq(note.body)
          expect(updated_note.sentiment_score).to eq(note.sentiment_score)
          expect(updated_note.sentiment_label).to eq(note.sentiment_label)
        end
      end
    end

    context 'when sentiment analysis fails during update' do
      let(:attributes) { { id: note.id, title: 'Updated Title', body: 'New body triggering error' } }

      before do
        allow_any_instance_of(SentimentAnalysisService)
          .to receive(:analyze)
          .and_raise(StandardError, 'API error')
      end

      it 'returns an error and does not update the note' do
        result = described_class.update_note(attributes)
        aggregate_failures do
          expect(result.success?).to be false
          expect(result.errors).to include('API error')
        end
      end
    end
  end

  describe '#delete_note' do
    context 'when the note exists' do
      let!(:note) { create(:note, title: 'Test Note', body: 'Some body text') }

      it 'deletes the note and returns success' do
        result = described_class.delete_note(note.id)
        aggregate_failures do
          expect(result[:success]).to be true
          expect(result[:errors]).to be_empty
          expect(Note.exists?(note.id)).to be false
        end
      end
    end

    context 'when the note does not exist' do
      it 'returns an error with success set to false' do
        result = described_class.delete_note(0)
        aggregate_failures do
          expect(result[:success]).to be false
          expect(result[:errors]).to include('Note not found')
        end
      end
    end
  end
end
