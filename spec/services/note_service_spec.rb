require 'rails_helper'

RSpec.describe NoteService, type: :service do
  describe '#create_note' do
    subject(:result) { NoteService.create_note(attributes) }

    context 'when valid attributes passed' do
      let(:attributes) { { title: 'Test Note', body: 'This is a positive note.' } }
      let(:sentiment_result) { { sentiment_score: 1.0, sentiment_label: 'positive' } }

      before do
        expect_any_instance_of(SentimentAnalysisService)
          .to receive(:analyze)
          .with(attributes[:body])
          .and_return(sentiment_result)
      end

      it 'creates a note with sentiment analysis results' do
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

  describe '#update_note' do
    let!(:note) { create(:note, title: 'Original Title', body: 'Original body', sentiment_score: 0.0, sentiment_label: 'neutral') }

    context 'when the body is changed' do
      let(:attributes) { { id: note.id, title: 'Updated Title', body: 'This is an updated positive note.' } }
      let(:sentiment_result) { { sentiment_score: 1.0, sentiment_label: 'positive' } }

      before do
        # Expect sentiment analysis only when the body is updated.
        expect_any_instance_of(SentimentAnalysisService)
          .to receive(:analyze)
          .with(attributes[:body])
          .and_return(sentiment_result)
      end

      it 'updates the note and recalculates sentiment' do
        result = NoteService.update_note(attributes)
        expect(result.success?).to be true
        updated_note = result.note
        expect(updated_note.title).to eq('Updated Title')
        expect(updated_note.body).to eq('This is an updated positive note.')
        expect(updated_note.sentiment_score).to eq(1.0)
        expect(updated_note.sentiment_label).to eq('positive')
      end
    end
  end
end
